#!/usr/bin/env sh
set -e

SCAN_DOMAINS=${SCAN_DOMAINS:-"example.com"}
SKIP_DOMAINS=${SKIP_DOMAINS:-"example.example.com"}
AMASS_OPTS=${AMASS_OPTS:-"-passive -include-unresolvable -noalts -T 0 -r 1.1.1.1"}  # https://github.com/OWASP/Amass#using-the-tool-suite
AQUATONE_OPTS=${AQUATONE_OPTS:-"-debug -save-body false -scan-timeout 300 -threads 1"}  # https://github.com/michenriksen/aquatone#command-line-options
ROLLBAR_TOKEN=${ROLLBAR_TOKEN:-""}

function scan() {
    echo "Starting amass scan of '$SCAN_DOMAINS'.\n" | tee -a scan.log
    amass ${AMASS_OPTS} -d ${SCAN_DOMAINS} -o hosts.txt | tee -a scan.log
    ./filter_domains.py | tee -a scan.log  # amass -bl does not work so have to filter.

    echo "\n\nStarting aquatone scan of discovered domains.\n" | tee -a scan.log
    touch aquatone_urls.txt
    cat hosts.txt | uniq | aquatone ${AQUATONE_OPTS} | tee -a scan.log
}

function report() {
    urls=`cat aquatone_urls.txt | wc -l`
    if [[ ${urls} -ge 0 ]]; then
        echo "Discovered URLs:" | tee -a scan.log
        cat aquatone_urls.txt | tee -a scan.log
        report_rollbar
    else
        echo "Found no URLs"
    fi
}

function report_rollbar() {
    if [[ ! -z "$ROLLBAR_TOKEN" ]]; then
        echo "Sending rollbar notification"
        title="Domain Scan has found $urls public (potentially vulnerable) URLs"
        body="==> Discovered URLs:\n"`cat aquatone_urls.txt`"\n\n==> Scan log:\n"`cat scan.log`
        echo "{\"data\": {\"environment\": \"external\", \"level\": \"warn\", \"title\": \"$title\", \"body\": {\"message\": {\"body\": \"$body\"}}}, \"access_token\": \"$ROLLBAR_TOKEN\"}" > rollbar.json
        curl -H "Content-Type: application/json" --data-binary "@rollbar.json" https://api.rollbar.com/api/1/item/
    fi
}

scan
report