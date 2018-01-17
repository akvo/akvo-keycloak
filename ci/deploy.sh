#!/usr/bin/env bash

set -eu

if [[ "${TRAVIS_BRANCH}" != "master" ]]; then
    exit 0
fi

if [[ "${TRAVIS_PULL_REQUEST}" != "false" ]]; then
    exit 0
fi

TAG=$(echo -n "${TRAVIS_COMMIT}" | cut -c-8)

IMAGE_NAME="akvo/keycloak-ha-mysql:${TAG}"

# Pushing images
docker login -u="${DOCKERHUB_USERNAME}" -p="${DOCKERHUB_PASSWORD}"
docker push "${DOCKER_IMAGE_NAME:=$IMAGE_NAME}"
