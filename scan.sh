#!/usr/bin/env sh
set -e

AQUATONE_REPO="/scan/reports"
DATE=`date +%d-%m-%y`
SCAN_DOMAINS=${SCAN_DOMAINS:-"example.com"}
SKIP_DOMAINS=${SKIP_DOMAINS:-"example.example.com"}
AMASS_OPTS=${AMASS_OPTS:-"-passive -include-unresolvable -noalts -T 0 -r 1.1.1.1"}  # https://github.com/OWASP/Amass#using-the-tool-suite
AQUATONE_OPTS=${AQUATONE_OPTS:-"-debug -save-body false -scan-timeout 300 -threads 1"}  # https://github.com/michenriksen/aquatone#command-line-options
ROLLBAR_TOKEN=${ROLLBAR_TOKEN:-""}
REPORTS_HOSTNAME=${REPORTS_HOSTNAME:-""}

function mk_scan_dir() {
    rm -rf $AQUATONE_REPO/$DATE
    mkdir -p $AQUATONE_REPO/$DATE 
    cd $AQUATONE_REPO/$DATE
}

function cleanup_scans() {
    find $AQUATONE_REPO/* -type d -mtime +90 | xargs rm -rf
}

function scan() {
    echo "Starting amass scan of '$SCAN_DOMAINS'.\n" | tee -a scan.log.txt
    amass ${AMASS_OPTS} -d ${SCAN_DOMAINS} -o hosts.txt | tee -a scan.log.txt
    filter_domains.py | tee -a scan.log.txt  # amass -bl does not work so have to filter.

    echo "\n\nStarting aquatone scan of discovered domains.\n" | tee -a scan.log.txt
    touch aquatone_urls.txt aquatone_report.html
    cat hosts.txt | uniq | aquatone ${AQUATONE_OPTS} | tee -a scan.log.txt
}

function report() {
    urls=`cat aquatone_urls.txt | wc -l`
    if [[ ${urls} -gt 0 ]]; then
        echo "Discovered URLs:" | tee -a scan.log.txt
        cat aquatone_urls.txt | tee -a scan.log.txt
        chmod -R go=rX,u=rwX ./*
        report_rollbar
    else
        echo "Found no URLs" | tee -a scan.log.txt
    fi
}

function report_rollbar() {
    if [[ ! -z "$ROLLBAR_TOKEN" ]]; then
        echo "Sending rollbar notification"
        this_report_page="https://$REPORTS_HOSTNAME/$DATE/aquatone_report.html"

        level="warning"
        title="Domain Scan has found $urls public (potentially vulnerable) URLs. Report: ${this_report_page}."
        if grep -i "takeover" aquatone_report.html; then
            level="error"
            title="Domain Scan has found a domain takeover threat! Report: ${this_report_page}."
        fi

        body="Recent reports: https://$REPORTS_HOSTNAME/"

        echo "{\"data\": {\"environment\": \"external\", \"level\": \"$level\", \"title\": \"$title\", \"body\": {\"message\": {\"body\": \"$body\"}}}, \"access_token\": \"$ROLLBAR_TOKEN\"}" > rollbar.json
        curl -H "Content-Type: application/json" --data-binary "@rollbar.json" https://api.rollbar.com/api/1/item/
    fi
}


mk_scan_dir
scan
report
cleanup_scans
