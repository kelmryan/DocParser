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
 printf "\n${BOLD}${MAGENTA}==========  %s  ==========${NORMAL}\n" "$@" >&2 
 echo "=====================  "$@"  ========================" >> output/test-results.txt    # TODO this method is never called
}

log_success() {
 printf "${GREEN}✔ %s${NORMAL}\n" "$@" >&2 
 suite=`echo "${0##*/}"  | sed 's/.sh//g'`
 #using a semicolon as a delimeter for reporting
 echo ""$suite"; PASS; "$@";">> output/test-results.txt
}

log_failure() {
 printf "${RED}❌ %s${NORMAL}\n" "$@" >&2 
 suite=`echo "${0##*/}"  | sed 's/.sh//g'`
 #using a semicolon as a delimeter for reporting
 echo ""$suite"; FAIL; "$@";">> output/test-results.txt
}

read_parameters() {
    echo "reading in $1 "
    IFS=$'\r\n' command eval 'results=($(cat $1))'
}

not_empty() {
    count=0
    # count the amount of lines logged
    if [[ -z $1 ]]; then
        log_failure "$1 log is empty"
        echo "FAIL "
        TEST_CHECK=${TEST_CHECK+1}
    else 
        log_success "$1 log was populated"
        echo -e "\n"
    fi        
}

logging_test() {

    echo "check $1 exists"
    check=0    
    for i in "${results[@]}"
        do
            if [[ "$i" == *"$1"* ]]; then
                echo "$i"
                log_success "$1 was found at $i"
                echo -e "\n" 
                check=$((check+1))       
            fi
        done
    if [[ "$check" -eq "0" ]]; then
        log_failure "$1 was not in found"
        echo "FAIL "        
        TEST_CHECK=${TEST_CHECK+1}
    fi
}

check_files() {

    echo "Verify $1 exists"
    if [[ grep –Fx "$1" "$results" ]]; then
        log_success "$1 was found"
    else
        log_failure "$1 was not found"
        echo "FAIL "        
        TEST_CHECK=${TEST_CHECK+1}
    fi
}