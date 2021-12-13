#!/bin/bash

# notes:
# CB = "clipboard"
THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
NOW_FILE_NAME=$(date +%Y-%m-%d_%H-%M-%S)

FLAGS="d"
[[ -n "${1}" ]] && FLAGS="${1}"
# flags
# d - duplicate, before copying the content of remote CB to local CB it stores it to localhost file (may be useful in some cases), TODO use as CB history (or Stack)

# set -e
# set -x
#shopt -s expand_aliases 2>/dev/null

declare -A RCB_SERVERS
# declare -A RCB_SERVERS_PATHS

[[ -f "${THIS_DIR}/config.sh" ]] || mv "${THIS_DIR}/config-sample.sh" "${THIS_DIR}/config.sh"

source "${THIS_DIR}/config.sh"

# prepare clipboard copy here

CB_DUPICATE="${THIS_DIR}/servers/"
if [[ "${FLAGS}" == *"d"* ]]; then
  mkdir -p "${CB_DUPICATE}"
  for SRV_LBL in "${!RCB_SERVERS[@]}"; do
    mkdir -p "${CB_DUPICATE}/${SRV_LBL}"
  done
fi

COLOR_RED='\033[0;31m'
COLOR_NC='\033[0m' # No Color
ERR_MSG="${COLOR_RED}ERROR${COLOR_NC}: "

# remote copy
# copies content to remote clipboard
_rc() {
  THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
  [[ -f "${THIS_DIR}/main.sh" ]] && source "${THIS_DIR}/main.sh"

  if [[ -z "${1}" ]]; then
    echo "${ERR_MSG}Missing server label, skipping"
    return
  fi
  SRV_LBL="${1}"
  SRV_SSH=${RCB_SERVERS[${SRV_LBL}]}
  # SRV_CMD="grep CLIPBOARD_FILE ~/.bashrc "
  SRV_CMD="source ~/.bashrc ; echo \${CLIPBOARD_FILE} "
  CMD_GET_CB_PATH="ssh ${SRV_SSH} '${SRV_CMD}'"
  # set -x

  SRV_CB_PATH=$(eval "${CMD_GET_CB_PATH}")
  if [[ -z "${SRV_CB_PATH}" ]]; then
    echo "${ERR_MSG}Unknown file SRV_CB_PATH, make sure that variable CLIPBOARD_FILE on remote server in ~/.bashrc exists and is not empty"
    return
  fi
  CMD_SCP_CB="scp ${SRV_SSH}:${SRV_CB_PATH} ${CB_DUPICATE}/${SRV_LBL}-c"
  # set +x
  eval "${CMD_SCP_CB}"
}

# remote paste
# copies content of remote clipboard file to current systems clipboard
_rp() {
  if [[ -z "${1}" ]]; then
    echo "Missing server label"
  fi
}

_c() {
  cat | xclip -r -selection clipboard
}

# copy from pipeline to clipboard and echo..
# more memory consuming than _c because output is stored as tmp variable
_ce() {
  # cat | xclip -r  -selection clipboard
  res=""
  while read -r data; do
    # printf "%s" "$data"
    if [[ -z "${res}" ]]; then
      res="${data}"
    else
      res="${res}\n${data}"
    fi
  done
  echo -e ${res}
  echo -e ${res} | xclip -r -selection clipboard
}

# paste from clipboard
_p() {
  xclip -selection clipboard -o
}

set +x
#
