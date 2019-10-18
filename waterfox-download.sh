#!/usr/bin/env bash
#
# Waterfox Script to print to screen the URl for the latest release
# To use with Angela (angela-d) installation instructions
# angelad@disroot.org
# https://notabug.org/angela
# https://gist.github.com/angela-d/5f6760f5512e8b8029aeda3cbb1d26dd
# Version 0.5.1
# Author: Marcelo dos Santos Mafra
# <https://stackoverflow.com/users/473433/msmafra>
# <https://www.reddit.com/user/msmafra/>
#
set -o errexit
set -o errtrace
set -o nounset
set -o pipefail
#set -o xtrace
function main() {
    printf "%s\n" "Checking the URL..."
    wfx_check_remote_existance
}

function wfx_get_url() {
    ## Variables ##
    local wfxpage
    local wfxurl
    # The official URL of the download page
    wfxpage="https://www.waterfox.net/releases/"
    #
    # Gets the URL for the download from the download page
    wfxurl=$(
        \wget --quiet --output-document=- "${wfxpage}" |
        \grep --extended-regexp --only-matching "(http|https)://[a-zA-Z0-9./?=_-]*" |
        \sort --unique |
        \grep --max-count=1 ".bz2"
    )
    printf "%s" "${wfxurl}"
}

function wfx_check_remote_existance() {
    local wfxfcheck
    local wfxurl
    wfxurl="$(wfx_get_url)"
    #
    # Checks if file is available remotely
    wfxfcheck=$(
        \wget --spider --show-progress --quiet --server-response "${wfxurl}" 2>&1 |
        \head --lines=1 |
        \awk 'NR==1{print $2}'
    )
    if [[ ! "${wfxfcheck}" = "200" ]];then
        # If the file is not there print an alert but print URL despite that
        printf "(!!) %s\n" "Could not be sure if the file is available, it seems not. Despite that, here is the URL: "
        printf "%s\n" "${wfxurl}"
        exit 1
    else
        # If the file is there print the message and URL
        printf "%s\n" "The file is there. Here is the URL for the most recent Waterfox: "
        printf "%s\n" "${wfxurl}"
        exit 0
    fi

}
main
