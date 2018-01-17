#!/bin/bash

if [ ${WAIT_FOR_DB} = "true" ]; then
    MAX=30
    TRIES=0
    DB="http://${MYSQL_PORT_3306_TCP_ADDR}:${MYSQL_PORT_3306_TCP_PORT}"
    curl --connect-timeout 2 ${DB} -s > /dev/null
    DB_UP=$?
    while [[ ${TRIES} -lt ${MAX} ]] && [[ ${DB_UP} -ne 0 ]]; do
        echo "Waiting for DB to start ..."
        sleep 5
        curl --connect-timeout 2 ${DB} -s > /dev/null
        DB_UP=$?
        let TRIES=${TRIES}+1;
    done
fi

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
