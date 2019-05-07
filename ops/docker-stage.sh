#!/usr/bin/env bash
set -e
source ./ops/env.sh
docker push ${DOCKER_TAG}