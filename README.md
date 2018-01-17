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

## Usage

    docker-compose up
    
This will create an environment with:

* MySQL instance, listening on port 3306
* Keycloak server, listening on port 8080
* JVM to run test with a REPL listening on port 47480

The Keycloak server will be configured with:

* [Master domain](http://localhost:8080/). Credentials: admin/admin  
* [Akvo domain](http://localhost:8080/auth/realms/akvo/account). 

#### Test

Run the test from the REPL or with:

    docker-compose exec tests /tests/import-and-run.sh test

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
