FROM openjdk:8-jdk as metrics

ARG KC_METRICS_SHA=dcd9f2aa

RUN set -ex; cd /tmp && \
    git clone --branch=master https://github.com/aerogear/keycloak-metrics-spi.git && \
    cd keycloak-metrics-spi && \
    git checkout -qf ${KC_METRICS_SHA} && \
    sed -i "s/^version '1\.0.*'/version '1.0-${KC_METRICS_SHA}'/g" build.gradle && \
    ./gradlew jar
