#!/bin/bash

if [ $KEYCLOAK_USER ] && [ $KEYCLOAK_PASSWORD ]; then
    keycloak/bin/add-user-keycloak.sh --user $KEYCLOAK_USER --password $KEYCLOAK_PASSWORD
fi

INIT_FILE="/keycloak-init/initial-import.json"

if [ -f ${INIT_FILE} ]; then
  IMPORT_FILE="-Dkeycloak.migration.action=import -Dkeycloak.migration.file=${INIT_FILE} -Dkeycloak.migration.strategy=IGNORE_EXISTING -Dkeycloak.migration.provider=singleFile"
fi

export HOSTNAME_IP=$(hostname -i)

exec /opt/jboss/keycloak/bin/standalone.sh -Djboss.bind.address.private=$HOSTNAME_IP ${IMPORT_FILE} $@
exit $?
