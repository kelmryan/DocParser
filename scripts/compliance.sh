#!/usr/bin/env bash

set -e
set -o pipefail

source scripts/common.sh

index_file=${1:-""}
comp_val=${2:-0}

TEST_CHECK=0

main() {

    if [ -f "test-results.txt" ]; then
        rm test-results.txt
    fi
    read_parameters 
    log_header "Configure Security"
    echo "Check for Keycloak Role Base"
    compliance_test 

    if [[ "$TEST_CHECK" -gt "0" ]]; then
        echo " Test had $TEST_CHECK Failures"
        return 1
    else
        return 0
    fi

} 

main "$@"