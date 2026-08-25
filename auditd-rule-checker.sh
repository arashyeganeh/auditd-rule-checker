#!/bin/bash

COLOR_CYAN='\e[0;36m'
COLOR_RED='\e[0;31m'
COLOR_GREEN='\e[0;32m'
COLOR_YELLOW='\e[0;33m'
COLOR_RESET='\e[0m'

DEFAULT_AUDITD_RULES_FILE="/etc/audit/audit.rules"

input="${1:-$DEFAULT_AUDITD_RULES_FILE}"

if [ ! -f "$input" ]; then
    echo -e "${COLOR_RED}Error: File '$input' does not exist${COLOR_RESET}" >&2
    exit 1
fi

if [ ! -r "$input" ]; then
    echo -e "${COLOR_RED}Error: File '$input' is not readable${COLOR_RESET}" >&2
    exit 1
fi

if [ ! -s "$input" ]; then
    echo -e "${COLOR_RED}Error: File '$input' is empty${COLOR_RESET}" >&2
    exit 1
fi


echo -e "${COLOR_CYAN}"
echo "#####################################"
echo "#### Checking Audit Watch Rules #####"
echo "#####################################"
echo -e "${COLOR_RESET}"

successes=()
errors=()

while IFS= read -r line
do

    if [[ "$line" == -w\ * ]]; then
        path=$(echo "$line" | awk '{print $2}')
        if [ -e "$path" ]; then
            successes[${#successes[@]}]="$line"
        else
            errors[${#errors[@]}]="$line"
        fi

    fi

done < "$input"

if [ ${#successes[@]} -gt 0 ]; then

    echo -e "\n ${COLOR_GREEN}"
    echo -e "###"
    echo -e "### Successes"
    echo -e "###"
    echo -e "\n ${COLOR_RESET}"

    for i in "${successes[@]}"
    do
        echo -e "${COLOR_GREEN}$i${COLOR_RESET}"
    done

fi

if [ ${#errors[@]} -gt 0 ]; then
    echo -e "\n ${COLOR_RED}"
    echo -e "###"
    echo -e "### Errors"
    echo -e "###"
    echo -e "\n ${COLOR_RESET}"

    for i in "${errors[@]}"
    do
        echo -e "${COLOR_RED}$i${COLOR_RESET}"
    done

fi

total=$((${#successes[@]} + ${#errors[@]}))

echo -e "\n"
echo -e "${COLOR_CYAN}Total: ${total} ${COLOR_RESET}"
echo -e "${COLOR_RED}Total error: ${#errors[@]} ${COLOR_RESET}"
echo -e "${COLOR_GREEN}Total success: ${#successes[@]} ${COLOR_RESET}"
echo -e "\n"
