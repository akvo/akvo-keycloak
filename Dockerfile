FROM jboss/keycloak:3.1.0.Final

ENV PROXY_ADDRESS_FORWARDING=true \
    JB_HOME=/opt/jboss \
    KC_HOME=/opt/jboss/keycloak

COPY docker-entrypoint.sh ${JB_HOME}
COPY theme/akvo/ ${KC_HOME}/themes/akvo/
COPY keycloak_configuration.txt ${KC_HOME}

RUN ${KC_HOME}/bin/jboss-cli.sh --file=${KC_HOME}/keycloak_configuration.txt && \
    rm -rf ${KC_HOME}/standalone/configuration/standalone_xml_history/current/* && \
    mkdir -p ${KC_HOME}/modules/system/layers/base/com/mysql/jdbc/main; \
    cd ${KC_HOME}/modules/system/layers/base/com/mysql/jdbc/main && \
    curl -O http://central.maven.org/maven2/mysql/mysql-connector-java/5.1.18/mysql-connector-java-5.1.18.jar && \
    curl -o ${KC_HOME}/providers/keycloak-monitoring-prometheus-1.1.0.jar \
    https://jitpack.io/com/github/larscheid-schmitzhermes/keycloak-monitoring-prometheus/1.1.0/keycloak-monitoring-prometheus-1.1.0.jar

COPY module.xml ${KC_HOME}/modules/system/layers/base/com/mysql/jdbc/main/

CMD ["-b", "0.0.0.0", "--server-config", "standalone-ha.xml"]
