#!/usr/bin/env bash
set -e
helm template helm/domain-scan --set scan_domains='{test.domain.com,test.domain.gov}' --set skip_domains='sub.test.domain.com'