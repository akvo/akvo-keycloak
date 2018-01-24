# Keycloak HA MySQL on Google Cloud Platform

## Base Dockerfile

The base code is from [Keycloak docker image](https://github.com/jboss-dockerfiles/keycloak/tree/2.5.5.Final/server)
plus the [MySQL](https://github.com/jboss-dockerfiles/keycloak/tree/2.5.5.Final/server-mysql)
specific changes

## Changes from base image

* `JDBC_PING` as discovery protocol with the same datasource `KeycloakDS`
* Disables `ip_mcast` at JGroups level
* Removes `udp` network stack at JGroups level
* Enables `proxy-address-forwarding`
* Added Akvo theme

## Usage

    docker-compose up

This will create an environment with:

* MySQL instance, listening on port 3306
* Keycloak server, listening on port 8080
* JVM to run test with a REPL listening on port 47480

The Keycloak server will be configured with:

* [Master domain](http://localhost:8080/). Credentials: admin/password
* [Akvo domain](http://localhost:8080/auth/realms/akvo/account). Credentials: jerome/password

#### Test

Run the test from the REPL or with:

    docker-compose exec tests /tests/import-and-run.sh test

#### Themes

There is a custom theme in the theme directory. Any edit in those files should be automatically picked up by Keycloak,
just refresh the page.

#### Notes

* The MySQL version must match the available version in Google Cloud SQL: https://cloud.google.com/sql/faq#version


### Environment variables

#### KEYCLOAK_LOGLEVEL

Specify the logging level for `org.keycloak` package

#### MYSQL_DATABASE

Specify name of MySQL database (optional, default is `keycloak`).

#### MYSQL_USER

Specify user for MySQL database (optional, default is `keycloak`).

#### MYSQL_PASSWORD

Specify password for MySQL database (optional, default is `keycloak`).

## Export Keycloak configuration

If you want to update the initial Keycloak configuration, you need to run:

    docker-compose stop keycloak1
    docker-compose run -d --name keycloak-export keycloak1 --server-config standalone-ha.xml -Dkeycloak.migration.action=export -Dkeycloak.migration.provider=singleFile -Dkeycloak.migration.file=/tmp/initial-import.json -Dkeycloak.migration.usersExportStrategy=REALM_FILE

It takes around a minute before the export is done. Look at the logs:

    docker logs keycloak-export | grep "Export finished successfully"

After that:

    docker cp keycloak-export:/tmp/initial-import.json test/keycloak/initial-import.json
    docker stop keycloak-export
    docker rm keycloak-export

## Building Prometheus event exporter

__Note:__ This can be deprecated once the aerogear team stars publishing the jars into a Maven repository

Pick a revision:

    export SHA=dcd9f2aa


Build the jar file:

    docker build --build-arg KC_METRICS_SHA="$SHA" -t akvo/kc-metrics -f metrics/Dockerfile metrics/


Copy the jar to `/providers` folder

    docker run --rm --volume "$PWD/providers:/providers" akvo/kc-metrics cp "/tmp/keycloak-metrics-spi/build/libs/keycloak-metrics-spi-1.0-$SHA.jar" /providers

Delete any previous jar from `providers` folder:

    git rm providers/keycloak-metrics-spi-1.0-<old-sha>.jar

Add and commit the new jar

    git add "providers/keycloak-metrics-spi-1.0-$SHA.jar"
    git commit
