#!/bin/bash

APP="hidden_super_star"
INSTALL_DIR="."
source "${INSTALL_DIR}/${APP}.conf" 2>/dev/null || printf ""
source "$XDG_CONFIG_HOME/${APP}.conf" 2>/dev/null || printf ""

bold_msg(){
    echo -e "\033[1;34m::\033[1;37m ${1}\033[0m"
}

if [[ "$1" == '' ]]; then
    echo 'Usage: random_courses.sh <number> <difficulty>'
    echo 'e for easy, n for normal, ex for expert and sex for super expert'
    exit
fi

if [[ "$2" == '' ]]; then
    echo 'Usage: random_courses.sh <number> <difficulty>'
    echo 'e for easy, n for normal, ex for expert and sex for super expert'
    exit
fi

bold_msg "Fetching course list..."
list_json="$(curl "https://tgrcode.com/mm2/search_endless_mode?count=$1&difficulty=$2")"
echo "$list_json" | jq -c '.courses[]' | while read course; do
    i=0
    bold_msg "Downloading $(echo "$course" | jq '.name')"
    curl "https://tgrcode.com/mm2/level_data/$(echo "$course" | jq '.course_id')" -o "${SMM2_SAVE}/$((120+$i)).bcd"
    i=$(($i+1))
done
