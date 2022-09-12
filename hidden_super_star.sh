#!/bin/bash


bold_msg(){
    echo -e "\033[1;34m::\033[1;37m ${1}\033[0m"
}

error(){
    echo "\033[1;31m$ {1}\033[0m"
}

refresh_courses(){
bold_msg "${STR_3}"

courses_with_name=()
for course in "${courses[@]}"
do
    tput sc
    printf "$STR_4 $course"
    md5="$(md5sum "${SMM2_SAVE}/course_data_${course}.bcd")"
    md5="${md5%% *}"
    tput rc
    printf "$STR_4 $course $md5"
    if [ ! -f "${HOME}/.cache/${APP}/$md5.json" ];then
        "${TOOST}" -p "${SMM2_SAVE}/course_data_${course}.bcd" --overworldJson "${HOME}/.cache/${APP}/$md5.json" | printf ""
    fi
    tput rc
    if [ ! -f "${HOME}/.cache/${APP}/$md5.json" ];then
        courses_with_name[${#courses_with_name[*]}]="$course | $STR_6"
    else
        courses_with_name[${#courses_with_name[*]}]="$course | $(jq -cr '.name' "${HOME}/.cache/${APP}/$md5.json")"
    fi
done
}

APP="hidden_super_star"
INSTALL_DIR="."
source "${INSTALL_DIR}/${APP}.conf" 2>/dev/null || printf ""
source "$XDG_CONFIG_HOME/${APP}.conf" 2>/dev/null || printf ""
source "${INSTALL_DIR}/include/get-choice.sh"
source "${INSTALL_DIR}/include/text_input.sh"

source "${INSTALL_DIR}/locales/en_US.sh"
source "${INSTALL_DIR}/locales/${LANG%.*}.sh" 2>/dev/null || printf "" # Load locale

echo ""
echo "${STR_1}"
echo "2022 By ${STR_2}"
echo ""

mkdir -p "${HOME}/.cache/${APP}" 2>/dev/null || printf ""

if [ "${1}" == "-h" ] || [ "${1}" == "--help" ]; then
    echo "$HLP_1"
    echo ""
    echo "$HLP_2"
    echo ""
    echo "$HLP_3"
    echo "$HLP_4"
    exit
fi

if [ "${1}" == "-c" ] || [ "${1}" == "--clean" ]; then
    rm -rf "${HOME}/.cache/${APP}"
    bold_msg "$STR_5"
    exit
fi

courses=("$(ls "$SMM2_SAVE" | grep ".bcd" | sed 's/\.bcd//g' | sed 's/course_data_//g')")
courses=(${courses[0]})

# load levels

refresh_courses


while true;do
    tput clear
    sleep 0.01s
    getChoice -q "$STR_7" -o "courses_with_name" -m "$(($(tput lines)-5))"

    selected_id=${selectedChoice%% *}
    choices=("$CHO_1" "$CHO_2")
    getChoice -q "$STR_8 ${selectedChoice} $STR_9" -o "choices"
    if [ "${selectedChoice}" == "$CHO_1" ]; then
        text_input "$STR_10" "course_id"
        bold_msg "${STR_11}"
        curl "https://tgrcode.com/mm2/level_data/${course_id/-/}" -o "/tmp/${APP}_temp.bcd"
        if [ "$(cat "/tmp/${APP}_temp.bcd" | jq -rc .error)" == "Invalid course ID" ]; then
            echo "${STR_12} ${STR_14}"
            read
        elif [ "$(cat "/tmp/${APP}_temp.bcd" | jq -rc .error)" == "Invalid course ID" ]; then
            echo "${STR_13} ${STR_14}"
            read
        else
            mv "/tmp/${APP}_temp.bcd"   "$SMM2_SAVE/course_data_${selected_id}.bcd"
        fi
        refresh_courses
    fi
done
