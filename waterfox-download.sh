#!/usr/bin/env bash
#
# Waterfox Script to print to screen the URl for the latest release
# To use with Angela (angela-d) "How to Install Waterfox on Linux"
# angelad@disroot.org
# https://notabug.org/angela
# https://gist.github.com/angela-d/5f6760f5512e8b8029aeda3cbb1d26dd
# Version 0.6.1
# Author: Marcelo dos Santos Mafra
# <https://stackoverflow.com/users/473433/msmafra>
# <https://www.reddit.com/user/msmafra/>
# declare -i arr=$(tput cols);i=0;while [[ i -lt "${arr}" ]];do $((i += 1));done
set -o errexit
set -o errtrace
set -o nounset
set -o pipefail
# set -o xtrace
function exit_stage_left {
    printf "So exit, Stage Left! %s" "$?"
}
function main() {
    printf "%s\n\n" "Checking the URLs..."
    wfx_check_remote_existance
    printf "\v%s %s\n" "Go to Angela (angela-d)'s How to Install Waterfox on Linux and follow the instrutions. :)" "https://gist.github.com/angela-d/5f6760f5512e8b8029aeda3cbb1d26dd"
}
function wfx_get_url() {
    ## Variables ##
    local wfxpage
    local wfxurl
    # The official URL of the download page
    wfxpage="https://www.waterfox.net/releases/"
    # Gets the URL for the download from the download page
    wfxurl=$(
        \wget --quiet --output-document=- "${wfxpage}" |
        \grep --extended-regexp --only-matching "(http|https)://[a-zA-Z0-9./?=_-]*" |
        \sort --unique |
        \grep --max-count=2 ".bz2"
    )
    printf "%s " "${wfxurl}"
    unset wfxpage
    unset wfxurl
}
function wfx_check_remote_existance() {
    # Obtains the URLs and checks if the files are avaible for download
    local wfxfcheck
    declare -a wfxurl
    wfxurl=($(wfx_get_url))
    for wurl in "${!wfxurl[@]}";do
    # Checks if file is available remotely
      wfxfcheck=$(
          \wget --spider --show-progress --quiet --server-response "${wfxurl[wurl]}" 2>&1 |
          \head --lines=1 |
          \awk 'NR==1{print $2}'
      )
      [[ "${wurl}" = 1 ]]&& branch="Current" || branch="Classic"
      if [[ ! "${wfxfcheck}" = "200" ]];then
          # If the file is not there print an alert but print URL despite that
          printf "=> (!!) Here is the URL for Waterfox %s Branch. Could not be sure if the file is available. It looks like is not yet avaible. (!!)\n" "${branch}"
          printf "%s\n\v" "${wfxurl[wurl]}"
      else
          # If the file is there print the message and URL
          printf "=> Here is the URL for Waterfox %s Branch most recent. The file is there.\n" "${branch}"
          printf "%s\n\v" "${wfxurl[wurl]}"
      fi
  done
  unset wfxfcheck
  unset wfxurl
}
# Run it
main "${@}"
