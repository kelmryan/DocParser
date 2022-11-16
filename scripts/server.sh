#!/bin/bash

set -e
set -x
set -o pipefail
# This script check security permission measures on the server

source scripts/common.sh
# path to server check
JENKINS_PATH=${1:-"/app/jenkins/jenkins/secrets"}
#permissions
PERMISSIONS=${2:-"700"}
#name of security mechanism
comp_name=${3:-"Jenkins Compliance"}
policy=${4:-""}
TEST_CHECK=0
return_perm=""
main() {

        log_header "${comp_name}"
        ssh_server "'stat -c '%a'' $JENKINS_PATH"
        if [ "$return_perm" == "" ]; then
           log_failure "Failed to get permission. check ssh command"
        else
           assert_permissions $return_perm $PERMISSIONS
        fi
        if [ ! -z "$policy"]; then
            ssh_server 'ps -ef | grep "jenkins"'
            index_file=$return_perm
            compliance_test
        fi
        if [[ "$TEST_CHECK" -gt "0" ]]; then
            log_failure " Test had $TEST_CHECK Failures"
        else
            log_success "${comp_name} test passed"
        fi

}

main "$@"