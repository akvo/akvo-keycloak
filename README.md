# Keycloak HA MySQL on Google Cloud Platform


## Building Keycloak from sources

See: [How to build Keycloak](build.md)

## Base Dockerfile

The base code is from [Keycloak docker image](https://github.com/jboss-dockerfiles/keycloak/tree/2.5.5.Final/server)
plus the [MySQL](https://github.com/jboss-dockerfiles/keycloak/tree/2.5.5.Final/server-mysql)
specific changes

## Changes from base image

* `JDBC_PING` as discovery protocol
* Disables `ip_mcast` at JGroups level

## Bulding Docker image

NOTE: Make sure you have a `keycloak-VERSION-tar.gz` in this folder
(produced by building from sources)

    docker build -t akvo/keycloak-ha-mysql:VERSION .

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

#### Changes from base image

New enviroment variables are available to configure GOOGLE_PING discovery protocol

* `GOOGLE_ACCESS_KEY`
* `GOOGLE_ACCESS_KEY_SECRET`
* `GOOGLE_LOCATION`

See GOOGLE_PING documentation for more info

* https://cloudplatform.googleblog.com/2016/02/JGroups-based-clustering-and-node-discovery-with-Google-Cloud-Storage.html
* http://jgroups.org/manual/index.html#_google_ping

When starting the Keycloak instance you can pass a number of environment variables to configure how it connects to MySQL. For example:

    docker run --name keycloak1 --link mysql:mysql \
	       -e MYSQL_DATABASE=keycloak \
		   -e MYSQL_USERNAME=keycloak \
		   -e MYSQL_PASSWORD=password \
		   -e GOOGLE_LOCATION=jgroups-bucket \
		   -e GOOGLE_ACCESS_KEY=GXXXXX \
		   -e GOOGLE_ACCESS_KEY_SECRET=YYYYYYY \
		   akvo/keycloak-ha-mysql

#### MYSQL_DATABASE

Specify name of MySQL database (optional, default is `keycloak`).

#### MYSQL_USER

Specify user for MySQL database (optional, default is `keycloak`).

#### MYSQL_PASSWORD

Specify password for MySQL database (optional, default is `keycloak`).
