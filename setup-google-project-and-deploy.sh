#!/usr/bin/env bash

## Creating a new Google Cloud Container project and deploys Keycloak to it
## First parameter should be the Google project name

set -eu

PROJECT_NAME=$1
DB_NAME=$PROJECT_NAME-db

echo "creating project"
gcloud projects create $PROJECT_NAME --set-as-default --enable-cloud-apis
gcloud config set compute/zone europe-west1-d

ACCOUNT=$(gcloud beta billing accounts list | grep True | head -n 1 | cut -f 1 -d\ )

if [ -z "$ACCOUNT" ]; then
    echo "Could not find a valid billing account"
    exit 1
fi

echo "Using billing account $ACCOUNT"
gcloud beta billing projects link $PROJECT_NAME --billing-account=$ACCOUNT
gcloud service-management enable container.googleapis.com
gcloud service-management enable sqladmin.googleapis.com

gcloud container clusters create $PROJECT_NAME-cluster --machine-type=g1-small --num-nodes=1 --scopes=https://www.googleapis.com/auth/cloud-platform

gcloud sql instances create $DB_NAME --activation-policy=ALWAYS --no-storage-auto-increase --backup --storage-type=HDD --storage-size=10GB --tier=db-f1-micro --gce-zone=europe-west1-d --database-version=MYSQL_5_6 --region europe-west1
# maybe you want also --enable-bin-log --backup

gcloud sql users create keycloak % -i $DB_NAME --password passwd

gcloud sql databases create keycloak -i $DB_NAME 

cat <<EOF > secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: keycloak
type: Opaque
data:
  keycloak_user: $(printf "admin" | base64)
  keycloak_password: $(printf "passwd" | base64)
  mysql_password: $(printf "passwd" | base64)
  mysql_instance: $(printf "$PROJECT_NAME:europe-west1:$DB_NAME=tcp:3306" | base64)
EOF

kubectl create -f ./secret.yaml
rm secret.yaml

SERVICE_ACCOUNT=`gcloud iam service-accounts list | grep default | rev | cut -f1 -d\  | rev`
gcloud iam service-accounts keys create credentials.json --iam-account=$SERVICE_ACCOUNT
kubectl create secret generic cloudsql-instance-credentials --from-file=credentials.json

rm credentials.json

cat <<EOF > add-kc-user
        - name: KEYCLOAK_USER
          valueFrom:
            secretKeyRef:
              name: keycloak
              key: keycloak_user
        - name: KEYCLOAK_PASSWORD
          valueFrom:
            secretKeyRef:
              name: keycloak
              key: keycloak_password
EOF

sed '/key: mysql_password/r add-kc-user' deployment.yaml > deployment-with-kc-user.yaml

kubectl apply -f deployment-with-kc-user.yaml

rm add-kc-user deployment-with-kc-user.yaml

kubectl expose deployment keycloak --type="LoadBalancer"

function external_ip() {
    echo $(kubectl get service keycloak | grep keyc | grep -v pending | tr -s " " | cut -f 3 -d\ )
}

EXTERNAL_IP=$(external_ip)

while [ -z "$EXTERNAL_IP" ]; do
    echo "Waiting for external ip to be allocated"
    sleep 10
    EXTERNAL_IP=$(external_ip)
done

cat <<EOF
Keycloak should be available at http://$EXTERNAL_IP:8080/

When done, run the command:
gcloud projects delete $PROJECT_NAME
EOF
