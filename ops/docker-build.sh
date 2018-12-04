#!/usr/bin/env bash
set -e
source ./ops/env.sh
docker build -t ${DOCKER_TAG} .