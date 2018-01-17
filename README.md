# Keycloak HA MySQL on Google Cloud Platform


## Building Keycloak from sources

See: [How to build Keycloak](build.md)

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

### Start a MySQL instance (local setup)

First start a MySQL instance using the MySQL docker image:

    docker run --name mysql \
	       -e MYSQL_DATABASE=keycloak \
		   -e MYSQL_USER=keycloak \
		   -e MYSQL_PASSWORD=password \
		   -e MYSQL_ROOT_PASSWORD=root_password \
		   -d mysql:5.7

#### Notes

* The MySQL version must match the available version in Google Cloud SQL: https://cloud.google.com/sql/faq#version
* Using the environment variables `MYSQL_USER`, `MYSQL_DATABASE` creates a user and a database locally.
  Make sure those are available when using the hosted MySQL.

### Environment variables

#### KEYCLOAK_LOGLEVEL

Specify the logging level for `org.keycloak` package

#### MYSQL_DATABASE

Specify name of MySQL database (optional, default is `keycloak`).

#### MYSQL_USER

Specify user for MySQL database (optional, default is `keycloak`).

#### MYSQL_PASSWORD

Specify password for MySQL database (optional, default is `keycloak`).
