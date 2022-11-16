#!/usr/bin/env bash

set -e
#set -x
#set -o pipefail
#the file will be used to check for valid policies that should be present
# Based on Security mechanisms in place for the particular 3rd party
#serice or application

source scripts/common.sh

#name of html to parse
index_file=${1:-""}
#page extension on website
sec_page=${2}
#name of security mechanism
comp_name=${3:-"need mechanism name"}
vuln=${4:-"no vulnerability listed"}
policy=$5
TEST_CHECK=0

main() {

    clean
    log_header "${comp_name}"
     # curl the jenkins page
    curl $JENKINS$sec_page >> $index_file
    if [[ "$vuln" == "fail" ]]; then
        echo "Checking for Plugin Failures"
        fail_plugin
    else
        echo " Checking for vulnerability $vuln"
        read_parameters
        plugin_vuln
    fi
    if [[ "$TEST_CHECK" -gt "0" ]]; then
        echo " Test had $TEST_CHECK Failures"
        return 1
    else
        return 0
    fi

}