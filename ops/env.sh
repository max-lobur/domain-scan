APP_VERSION=`cat helm/domain-scan/values.yaml | grep tag: | cut -d':' -f2 | awk '{$1=$1};1'`
DOCKER_TAG=${DOCKER_TAG:-"quay.io/verygoodsecurity/domain-scan:$APP_VERSION"}