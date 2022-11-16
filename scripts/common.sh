#!/bin/bash

export TERM=xterm-256color
# Make the tests look pretty :)
if command -v tput &>/dev/null && tty -s; then
 RED=$(tput setaf 1)
 GREEN=$(tput setaf 2)
 MAGENTA=$(tput setaf 5)
 NORMAL=$(tput sgr0)
 BOLD=$(tput bold)
 RESET=$(tput sgr0)
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
 printf "${RESET}"
}

log_success() {
 printf "${GREEN}✔ %s${NORMAL}\n" "$@" >&2
 #using a pipe as a delimeter for reportingi
 echo ""Stage: $suite"| PASS | "$@";">> results/"${comp_name}.txt"
 echo "*****************************"
printf " ${RESET}"
}

log_failure() {
 printf "${RED}❌ %s${NORMAL}\n" "$@" >&2
 #using a pipe as a delimeter for reporting
 echo ""Stage: $suite"| FAIL | "$@";">> results/"${comp_name}.txt"
 echo "*****************************"
 printf " ${RESET}"
}

#Checks permission of a given path
assert_permissions() {

    if [ "$1" == "$2" ]; then
        log_success "$1 has proper permissions"
    else
        log_failure "$1 does not have proper permissions. Was $1 instead of $2"
        echo "FAIL $1 is not $2"
        TEST_CHECK=$((TEST_CHECK+1))
    fi
}
#clean up any old artifacts
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

            echo "checking if string exists in $index_file"
            #TODO if we wanted to make this EXACT, we can add -x but policy would be extremly strict

            if  grep -Fq "$i" $index_file; then
                echo "found string "
                log_success "Check was found for for $comp_name"
            else
                log_failure "String $i was not found in $index_file"
                echo "FAIL $comp_name "
                TEST_CHECK=$((TEST_CHECK+1))
            fi
        done
}

#check that policy does NOT exist in returned index
negative_test() {
    check=0
    for i in "${results[@]}"
        do
            echo "checking that a specific string does not exists in $index_file"
            if  grep -Fq "$i" $index_file; then
                log_failure "String $i was found in $index_file"
                echo "FAIL $comp_name "
                TEST_CHECK=$((TEST_CHECK+1))
            else
                echo "*****$?***** $i not found in $index_file"
                log_success "String was not found"
            fi
        done
}
#Count instances
occurance_count()
{
    array="$1"
    if [  -z ${occur+x} ]; then
            occur=0
    fi
    for i in "${array[@]}"
        do
            echo "Check that string assertion occurs $occur times"
            count=$(grep -F "$i" $index_file | wc -l)
            if [[ "$count" == "$occur" ]]; then
                log_success "$i occured $occur times"
            else
                log_failure "$i occured $count times should have been $occur times"
                echo "FAIL $i "
                TEST_CHECK=$((TEST_CHECK+1))
            fi
        done
}
#read policy into an array
read_parameters() {
    #TODO need to pass this in as a $1 param
    echo "reading in $policy"
    IFS=$'\r\n' command eval 'results=($(cat $policy))'
}

#TODO combine regex to parse out specific html based on config files
fail_plugin() {
    # capture specific failed plugins and parse it into the report
    ref=$(cat $index_file | grep -Po '(?<=<div class="plugin-name failed-plugin with-plugin-wrapper">).*?(?=<\/a>)')
    if [[ ! -z "$ref" ]]; then
       plugin=($(echo $ref | grep -Po '(?<=target="_blank">).+?(?= )'))
       printf "The following plugins have failures with errors: \n"
       for i in "${plugin[@]}"
       do
           echo "* $i *"
           TEST_CHECK=$((TEST_CHECK+1))
           log_failure "$i needs to be updated or removed"
       done
    else
       log_success "All plugins are running as intended"
    fi
}

plugin_vuln() {
# parses for  specific vulnerabilities in plugins using policy as regex
    ref=$(cat $index_file | grep -Po "${results[0]}")
    if [[ ! -z "$ref" ]]; then
    # Grep for the vulnerability in the parsed html even if null
       plugin=$(echo $ref | grep -Po "${results[1]}" | grep -Fo "$vuln") || true
       if [ -z "$plugin" ]; then
           log_success "$vuln not found"
       else
           # Read into an array
           IFS=$'\n'; set -f; arr=($plugin)
           occurance_count "$arr"
           log_failure "The following plugins have $count findings of $vuln: \n"
       fi
    else
       log_success "All plugins are running as intended"
       printf "The following plugins have $count findings of $vuln: \n"
    fi
}
# Grep the regex for the plugins and verify that thjey are checked
security_warn() {
    echo " Verify that checkbox for Security warnings are checked"
    warn=$(cat $index_file | grep -Po "${results[0]}")
    IFS=$'\n'; set -f; arr=($warn)
    for i in "${arr[@]}"
    do
            if [ $(echo "$i" | grep -Fo "${results[1]}") ]; then
        # extracting the name of the security warning
            plug=$(echo $i | awk '{print substr($3, 6, 100)}')
            log_success " $plug is checked"
        else
            log_failure "Supressed security warning needs to be checked"
        fi
    done
}
ssh_server() {

    echo "$BASTION_PUB" > bastion.pem
    chmod 400 bastion.pem
    echo "SSH to bastion"
    #Have to sleep in order to give ssh command a chance. may have to increase
    return_perm=$(ssh -o StrictHostKeyChecking=no -i bastion.pem ${BASTION} '$JENKINS_SERVER | sleep 1 | ssh -i jenkins.pem '$JENKINS_SERVER' '"$1" '')
    if [ "$?" != "0" ]; then
        log_failure "Failed to log into jump box. Check IP, pem or username"
        TEST_CHECK=$((TEST_CHECK+1))
    fi

}