#!/usr/bin/env bash

set -e

BRANCH_NAME="${TRAVIS_BRANCH:=unknown}"

if [ -z "$TRAVIS_COMMIT" ]; then
    export TRAVIS_COMMIT=local
fi

TAG=$(echo -n "${TRAVIS_COMMIT}" | cut -c-8)
export IMAGE_NAME="akvo/keycloak-ha-mysql:1.${TRAVIS_BUILD_NUMBER}.${TAG}"

docker build -t "${DOCKER_IMAGE_NAME:=$IMAGE_NAME}" .

docker-compose -f docker-compose.yml -f docker-compose.ci.yml up -d --build
docker-compose -f docker-compose.yml -f docker-compose.ci.yml run tests /tests/import-and-run.sh test