#!/bin/bash

export TERM=xterm-256color
# Make the tests look pretty :)
if command -v tput &>/dev/null && tty -s; then
 RED=$(tput setaf 1)
 GREEN=$(tput setaf 2)
 MAGENTA=$(tput setaf 5)
 NORMAL=$(tput sgr0)
 BOLD=$(tput bold)
else
 RED=$(echo -en "\e[31m")
 GREEN=$(echo -en "\e[32m")
 MAGENTA=$(echo -en "\e[35m")
 NORMAL=$(echo -en "\e[00m")
 BOLD=$(echo -en "\e[01m")
fi

log_header() {
 if [ ! -d "results" ]; then
    mkdir results
 fi
 printf "\n${BOLD}${MAGENTA}==========  %s  ==========${NORMAL}\n" "$@" >&2
 echo "=====================  "$@"  ========================" >> results/"${comp_name}.txt"
}

log_success() {
 printf "${GREEN}✔ %s${NORMAL}\n" "$@" >&2
 suite=`echo "${0##*/}"  | sed 's/.sh//g'`
 #using a pipe as a delimeter for reporting
 echo ""Stage: $suite"| PASS | "$@";">> results/"${comp_name}.txt"
 echo "*****************************"
}

log_failure() {
 printf "${RED}❌ %s${NORMAL}\n" "$@" >&2
 suite=`echo "${0##*/}"  | sed 's/.sh//g'`
 #using a pipe as a delimeter for reporting
 echo ""Stage: $suite"| FAIL | "$@";">> results/"${comp_name}.txt"
 echo "*****************************"
}
#*****************************************

#Checks permission of a given path
assert_permissions() {

    if [ "$1" == "$2" ]; then
        log_success "$1 has proper permissions"
    else
        log_failure "$1 does not have proper permissions. Was $1 instead of $2"
        echo "FAIL $1 is not $2"
        TEST_CHECK=${TEST_CHECK+1}
    fi
}
#clean up anyold artifacts
clean()
{
    if [ -f "$index_file" ]; then
        echo "removing excess html"
        rm -rf $index_file
    fi
}
#check if policy is in curl'd results
compliance_test() {
    for i in "${results[@]}"
        do
            echo "checking if $i exists in $index_file"
            if  grep -Fq "$i" $index_file; then
                echo "found $i"
                log_success "$i was found"
            else
                log_failure "$i was not found in $index_file"
                echo "FAIL "
                TEST_CHECK=${TEST_CHECK+1}
            fi
        done
}

#Count instances
occurance_count()
{
    for i in "${results[@]}"
        do
            echo "Check that $i occurs $occur times"
            count=$(grep -F "$i" $index_file | wc -l)
            if [[ "$count" == "$occur" ]]; then
                log_success "$i occured $occur times"
            else
                log_failure "$i occured $count times should have been $occur times"
                echo "FAIL $i "
                TEST_CHECK=${TEST_CHECK+1}
            fi
        done
}
#check that policy does NOT exist in returned index
negative_test() {
    check=0
    for i in "${results[@]}"
        do
            echo "checking if $i does not exists in $index_file"
            if  grep -Fq "$i" $index_file; then
                log_failure "$i was found in $index_file"
                echo "FAIL $i "
                TEST_CHECK=${TEST_CHECK+1}
            else
                echo "*****$?***** $i not found in $index_file"
                log_success "$i not found"
            fi
        done
}

#read policy into an array
read_parameters() {
    echo "reading in $policy "
    IFS=$'\r\n' command eval 'results=($(cat $policy))'
}

regex_log() {
    ref=$( cat $index_file | grep -Po '(?<=<a rel=noopener noreferrer href=).*?(?= )')
    plugin=$(grep -Po '(?<=target=_blank>).+?(?=<\/a>)')
    reason=$(grep -Po '(?<=<pre>).+?(?=<\/pre>)|(?<=<pre>).+?(?=\()')
}

ssh_server() {
    
    #chmod 400 key.pem.pem
    return_perm=$(ssh -o StrictHostKeyChecking=no -i key.pem ${BASTION} '$JENKINS_SERVER | sleep 1 | ssh -i jenkins.pem '$JENKINS_SERVER' 'stat -c '%a' $JENKINS_PATH'')
    if [ "$?" != "0" ]; then
        log_failure "Failed to log into jump box. Check IP, pem or username"
        TEST_CHECK=${TEST_CHECK+1}
    fi

}