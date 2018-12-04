#!/usr/bin/env bash
set -e
helm package ./helm/domain-scan/ -d ./charts
helm repo index ./charts