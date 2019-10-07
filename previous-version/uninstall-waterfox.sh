#!/usr/bin/env bash
#
# Waterfox Uninstallation for Production version
# Version 0.8.8
# Author: Marcelo dos Santos Mafra
# <https://stackoverflow.com/users/473433/msmafra>
# <https://www.reddit.com/user/msmafra/>
#
set -o errexit
set -o errtrace
set -o nounset
set -o pipefail
#set -o xtrace
## Variables ##
readonly wfxdest="/usr/lib64/"
readonly wfxexec="/usr/bin/waterfox"
readonly wfxdesktop="/usr/share/applications/waterfox.desktop"
readonly wfxpath="/usr/lib64/waterfox"
readonly whoisit=$(\whoami | \awk '{print $1}' | \tr -d "\n")
readonly rstall="\e[0m"
readonly rstbold="\e[21m"
readonly bold="\e[1m"
readonly red="\e[31m"
readonly grn="\e[32m"
readonly blu="\e[34m"
readonly yel="\e[93m"
## Functions ##
function my_name() {
    is_earl=$(basename "${0}")
    # Or not
    printf "${is_earl}"
}

function wfx_uninstallation( ){

    local this_script="$(my_name)"
    if [[ "${whoisit}" = "root" ]];then

        printf "${bold}-- %s --${rstall}\n" "Script To Uninstall Waterfox From /usr/lib64/"

        printf "${yel}Removing files from ${bold}%s${rstall}\n" "${wfxpath}"
        if [[ -d "${wfxpath}" ]];then
            \rm --verbose --recursive --force "${wfxpath}"/*
        fi

        printf "${yel}Deleting ${bold}%s${rstall}\n" "${wfxdesktop}"
        if [[ -e "${wfxdesktop}" ]];then
            \rm --verbose --force "${wfxdesktop}"
        fi

        printf "${yel}Deleting ${bold}%s${rstall}\n" "${wfxexec}"
        if [[ -e "${wfxexec}" ]];then
            \rm --verbose --force "${wfxexec}"
        fi

        printf "${yel}Removing the directory ${bold}%s${rstall}\n" "${wfxpath}"
        if [[ -d "${wfxpath}" ]];then
            \rm --verbose --dir --recursive --force "${wfxpath}"
        else
            printf "${bold}%s${rstall} is not a directory or does not exist.\n" "${wfxpath}"
            exit 1
        fi

        printf "${grn}%s\n" "Leaving..."

    else

        printf "Run me as root \n sudo ./%s %b\n" "${this_script}"
        exit 1

    fi
}
wfx_uninstallation
