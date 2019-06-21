#!/usr/bin/env bash
#
# Author: Marcelo dos Santos Mafra
# <https://stackoverflow.com/users/473433/msmafra>
# <https://www.reddit.com/user/msmafra/>
#
# Waterfox Uninstallation Script for the former to be waterfox-install.sh (/usr/lib64/)
#
#/ Usage: SCRIPTNAME [OPTIONS]... [ARGUMENTS]...
#/
#/ OPTIONS
#/   -h, --help
#/                Print this help message
set -o errexit
set -o errtrace
set -o nounset
set -o pipefail
#set -o xtrace
# Unintall Waterfox from /usr/lib64
__dir="$(cd "$(dirname "${BASH_SOURCE[${__b3bp_tmp_source_idx:-0}]}")" && pwd)"
__file="${__dir}/$(basename "${BASH_SOURCE[${__b3bp_tmp_source_idx:-0}]}")"
__base="$(basename "${__file}" .sh)"
__invocation="$(printf %q "${__file}")$((($#)) && printf ' %q' "$@" || true)"

### Functions ##############################################################################

function __see_ya_even () {

    info "Say goodnight, Babs. Babs: Goodnight, Babs."

}

function help () {

    if [[ "${__helptext:-}" ]]; then
        echo "" 1>&2
        echo " ${__helptext}" 1>&2
        echo "" 1>&2
        echo "  ${__usage:-No usage available}" 1>&2
        echo "" 1>&2
    fi

    exit 1

}

[[ "${__usage+x}" ]] || read -r -d '' __usage <<-'EOF' || true # exits non-zero when EOF encountered
      sudo ./uninstall-waterfox.sh
EOF

[[ "${__helptext+x}" ]] || read -r -d '' __helptext <<-'EOF' || true # exits non-zero when EOF encountered
 Please run as root
EOF

readonly whoisit=$(\whoami | \awk '{print $1}' | \tr -d "\n")
readonly rstall="\e[0m"
readonly rstbold="\e[21m"
readonly bold="\e[1m"
readonly red="\e[31m"
readonly yel="\e[93m"

if [[ "${whoisit}" = "root" ]]
then

    printf "${bold}-- %s --${rstall}\n\n" "Script To Uninstall Waterfox From /usr/lib64/"

    wfxdest="/usr/lib64/"
    wfxexec="/usr/bin/waterfox"
    wfxdesktop="/usr/share/applications/waterfox.desktop"
    wfxpath="/usr/lib64/waterfox"

    printf "${yel}Removing files from %s${rstall}\n" "${wfxpath}"
    if [[ -d "${wfxpath}" ]];then
        echo \rm --verbose --recursive --force "${wfxpath}"/*
    fi

    printf "${yel}Deleting %s${rstall}\n" "${wfxdesktop}"
    if [[ -e "${wfxdesktop}" ]];then
        echo \rm --verbose --force "${wfxdesktop}"
    fi

    printf "${yel}Deleting %s${rstall}\n" "${wfxexec}"
    if [[ -e "${wfxexec}" ]];then
        echo -e \rm --verbose --force "${wfxexec}"
    fi

    printf "${yel}Removing the directory %s${rstall}\n" "${wfxpath}"
    if [[ -d "${wfxpath}" ]];then
        echo \rm --verbose --dir --recursive --force "${wfxpath}"
    else
        printf "%s is not a directory or does not exist.\n" "${wfxpath}"
        exit 1
    fi

    printf "%s\n" "Leaving..."

else

    help
    exit 1

fi
