FROM jboss/keycloak:3.1.0.Final

ENV PROXY_ADDRESS_FORWARDING true
ENV JB_HOME /opt/jboss
ENV KC_HOME ${JB_HOME}/keycloak
ENV CFG_FILE ${KC_HOME}/standalone/configuration/standalone-ha.xml
ENV WEB_XML ${KC_HOME}/modules/system/layers/keycloak/org/keycloak/keycloak-server-subsystem/main/server-war/WEB-INF/web.xml

ADD docker-entrypoint.sh ${JB_HOME}
ADD themes/akvo/ ${KC_HOME}/themes/akvo/
ADD keycloak_configuration.txt ${KC_HOME}

RUN ${KC_HOME}/bin/jboss-cli.sh --file=${KC_HOME}/keycloak_configuration.txt && \
    rm -rf ${KC_HOME}/standalone/configuration/standalone_xml_history/current/* && \
    mkdir -p ${KC_HOME}/modules/system/layers/base/com/mysql/jdbc/main; \
    cd ${KC_HOME}/modules/system/layers/base/com/mysql/jdbc/main && \
    curl -O http://central.maven.org/maven2/mysql/mysql-connector-java/5.1.18/mysql-connector-java-5.1.18.jar

ADD module.xml ${KC_HOME}/modules/system/layers/base/com/mysql/jdbc/main/

CMD ["-b", "0.0.0.0", "--server-config", "standalone-ha.xml"]
