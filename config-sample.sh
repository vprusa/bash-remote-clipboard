#!/bin/bash
############################################################
# vprusa, 2021, prusa.vojtech@gmail.com
############################################################

# notes:
# RCB = "remote clipboard"


# for SRV_LBL in "${!RCB_SERVERS[@]}"; do echo "$SRV_LBL - ${RCB_SERVERS[$SRV_LBL]}"; done
#
# CB = "clipboard"
THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# set -e
# set -x
#shopt -s expand_aliases 2>/dev/null

FLAGS=""
# r - install remote
# l - install local
[[ -n "${1}" ]] && FLAGS="${1}"

RCB_FILES_REL_DIR="~/.local/rclipboard"
# RCB_FILES_REL_DIR="${USER_HOME}/.local/rclipboard"
# RCB_FILES_DIR=$(eval "realpath ${RCB_FILES_REL_DIR}")
# RCB_FILES_DIR=$(realpath ${RCB_FILES_REL_DIR})
RCB_FILES_DIR="${HOME}/.local/rclipboard"
RCB_FILES="${RCB_FILES_DIR}/rcb"
LAST_USED_FILE="${RCB_FILES_DIR}/rcb-last"

POSTFIX=".example-domain.cz"

# TODO: use SSH config file aliases..
declare -A RCB_SERVERS
RCB_SERVERS=(
  ["server_label"]="ssh user@domain-name.cz"
  ["AAAA"]="ssh user@serverAAAA${POSTFIX}"
  ["A"]="ssh user@serverAAAA${POSTFIX}"
)


COLOR_RED='\033[0;31m'
COLOR_NC='\033[0m' # No Color
ERR_MSG="${COLOR_RED}ERROR${COLOR_NC}: "

# for SRV_LBL in "${!RCB_SERVERS[@]}"; do echo "$SRV_LBL - ${RCB_SERVERS[$SRV_LBL]}"; done

set +x
#
