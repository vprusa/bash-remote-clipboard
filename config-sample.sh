#!/bin/bash
############################################################
# vprusa, 2021, prusa.vojtech@gmail.com
############################################################

# notes:
# RCB = "remote clipboard"

RCB_FILES="~/.local/rclipboard/rcb"

POSTFIX=".example-domain.cz"

# TODO: use SSH config file aliases..
declare -A RCB_SERVERS
RCB_SERVERS=(
  ["server_label"]="ssh user@domain-name.cz"
  ["AAAA"]="ssh user@serverAAAA${POSTFIX}"
  ["A"]="ssh user@serverAAAA${POSTFIX}"
)

# for SRV_LBL in "${!RCB_SERVERS[@]}"; do echo "$SRV_LBL - ${RCB_SERVERS[$SRV_LBL]}"; done
#
