#!/usr/bin/env bash
#
# Waterfox uninstallation for the production one
# Version 0.9.5
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
readonly whoisit=$(\id --user --name | \awk --sandbox '{print $1}' | \tr --delete "\n")
readonly rstall="\e[0m"
# readonly rstbold="\e[21m"
readonly bold="\e[1m"
readonly red="\e[31m"
readonly grn="\e[32m"
# readonly blu="\e[34m"
readonly yel="\e[93m"
## Functions ##
function exit_stage_left {
    printf "So exit, Stage Left! %s" "$?"
}
trap exit_stage_left EXIT ERR # Elegant exit
function say_my_name() {
    local is_earl
    is_earl=$(basename "${0}")
    # Or not
    printf "%s" "${is_earl}"
}

function wfx_uninstallation( ) {

    local this_script
    this_script="$(say_my_name)"
    if [[ "${whoisit}" = "root" ]];then

        printf "%s\n Script To Uninstall Waterfox From %s %s" "${bold}" "${wfxdest}" "${rstall}"

        printf "%s%sRemoving files from %s%s\n" "${yel}" "${bold}" "${wfxpath}" "${rstall}"
        if [[ -d "${wfxpath}" ]];then
            \rm --verbose --recursive --force "${wfxpath:?}"/*
        fi

        printf "%s%sDeleting %s%s\n" "${yel}" "${bold}" "${wfxdesktop}" "${rstall}"
        if [[ -e "${wfxdesktop}" ]];then
            \rm --verbose --force "${wfxdesktop}"
        fi

        printf "%s%sDeleting %s%s\n" "${yel}" "${bold}" "${wfxexec}" "${rstall}"
        if [[ -e "${wfxexec}" ]];then
            \rm --verbose --force "${wfxexec}"
        fi

        printf "%s%sRemoving the directory %s%s\n" "${yel}" "${bold}" "${wfxpath}" "${rstall}"
        if [[ -d "${wfxpath}" ]];then
            \rm --verbose --dir --recursive --force "${wfxpath}"
        else
            printf "%s%s%s is not a directory or does not exist.%s\n" "${red}" "${bold}" "${wfxpath}" "${rstall}"
            exit 1
        fi

        printf "%s\n Leaving...%s" "${grn}" "${rstall}"

    else

        printf "Run with super user priviledges \n sudo ./%s\n" "${this_script}"
        exit 1

    fi
}
wfx_uninstallation
