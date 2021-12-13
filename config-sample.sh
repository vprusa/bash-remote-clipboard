#!/bin/bash
############################################################
# vprusa, 2021, prusa.vojtech@gmail.com
############################################################
# TODO  `mv config-sample.sh config.sh`

# notes:
# CB = "clipboard"
# THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

# set -e
# set -x
# shopt -s expand_aliases 2>/dev/null

POSTFIX=".example-domain.cz"

# TODO: use SSH config file aliases..? nah, its possible, but does not fit the way I use it..
declare -A RCB_SERVERS
RCB_SERVERS=(
  ["server_label"]="user@domain-name.cz"
  ["AAAA"]="user@serverAAAA${POSTFIX}"
  ["A"]="serverAAAA${POSTFIX}"
)

# TODO if there is missing env var ${CLIPBOARD_FILE} on server side
declare -A RCB_SERVERS_PATHS
RCB_SERVERS_PATHS=(
  ["swordfish"]="/home/user//path/to/file/clipboard/cb" # PATH to file (it will be expanded to '*/clipboard/cb-p' and '*/clipboard/cb-c' files)
)

# for SRV_LBL in "${!RCB_SERVERS[@]}"; do echo "$SRV_LBL - ${RCB_SERVERS[$SRV_LBL]}"; done

#
