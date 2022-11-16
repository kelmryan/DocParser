#!/usr/bin/env bash

set -e
#set -x
#set -o pipefail
# This script will parse an api call back to an index file in which
#the file will be used to check for valid policies that should be present
# Based on Security mechanisms in place for the particular 3rd party
#serice or application

source scripts/common.sh

#name of html to parse
index_file=${1:-""}
#policy config file
policy=${2:-0}
#page extension on website
sec_page=${3}
#name of security mechanism
comp_name=${4}
#Do a instance count (optional)
occur=${5:-0}
TEST_CHECK=0

main() {

    clean
    log_header "${comp_name}"
     # curl the jenkins page
    curl $JENKINS$sec_page >> $index_file
    read_parameters
    echo "Check for $comp_name"
    compliance_test
    if [ $occur != 0 ]; then
        occurance_count "$results"
    fi
    if [[ "$TEST_CHECK" -gt "0" ]]; then
        echo " Test had $TEST_CHECK Failures"
        return 1
    else
        return 0
    fi

}