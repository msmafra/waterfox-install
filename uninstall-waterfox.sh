#!/usr/bin/env bash
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

function emergency () {                                __b3bp_log emergency "${@}"; exit 1; }
function alert ()     { [[ "${LOG_LEVEL:-0}" -ge 1 ]] && __b3bp_log alert "${@}"; true; }
function critical ()  { [[ "${LOG_LEVEL:-0}" -ge 2 ]] && __b3bp_log critical "${@}"; true; }
function error ()     { [[ "${LOG_LEVEL:-0}" -ge 3 ]] && __b3bp_log error "${@}"; true; }
function warning ()   { [[ "${LOG_LEVEL:-0}" -ge 4 ]] && __b3bp_log warning "${@}"; true; }
function notice ()    { [[ "${LOG_LEVEL:-0}" -ge 5 ]] && __b3bp_log notice "${@}"; true; }
function info ()      { [[ "${LOG_LEVEL:-0}" -ge 6 ]] && __b3bp_log info "${@}"; true; }
function debug ()     { [[ "${LOG_LEVEL:-0}" -ge 7 ]] && __b3bp_log debug "${@}"; true; }

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

readonly whoisit=$(whoami | awk '{print $1}' | tr -d "\n")

if [[ "${whoisit}" = "root" ]];then

echo -e "Uninstall Waterfox from /usr/lib64\n"

wfxdest="/usr/lib64/"
wfxexec="/usr/bin/waterfox"
wfxdesktop="/usr/share/applications/waterfox.desktop"
wfxpath=""/usr/lib64/waterfox/""

echo -e "Removing files from $wfxpath"
rm --verbose --recursive --force $wfxpath*

echo -e "Deleting $wfxdesktop"
rm --verbose --force $wfxdesktop

echo -e "Deleting $wfxexec"
rm --verbose --force $wfxexec

echo -e "Removing the directory"
rm --verbose --dir --recursive --force /usr/lib64/watefox

echo -e "\nLeaving..."

else

  help
  exit 1

fi
