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
 echo ""$suite"; PASS; "$@";">> test-results.txt
}

log_failure() {
 printf "${RED}❌ %s${NORMAL}\n" "$@" >&2 
 suite=`echo "${0##*/}"  | sed 's/.sh//g'`
 #using a semicolon as a delimeter for reporting
 echo ""$suite"; FAIL; "$@";">> test-results.txt
}

read_parameters() {
    echo "reading in $comp_val "
    IFS=$'\r\n' command eval 'results=($(cat $comp_val))'
}


compliance_test() {

    echo "checking if ${results[@]} exists"
    check=0    
    for i in "${results[@]}"
        do
            echo $i
            if grep -Fq "$i" $index_file; then
                echo "found $i"
                log_success "$i was found"
            else 
                log_failure "$i was not found in $index_file"
                echo "FAIL "        
                TEST_CHECK=${TEST_CHECK+1}
            fi
        done
}