#!/bin/bash
############################################################
# vprusa, 2021, prusa.vojtech@gmail.com
############################################################

# notes:
# RCB = "Remote ClipBoard"
# basically: remote clipboard is a scp wrapper and local clipboard is xclip wrapper 
# for both the idea is not to have imposible number of tmp files and have them in 1 known place
# '_rc' and '_rp' do not need 'source ./config.sh' and 
# '_lc' and '_lp' do need 'source ./config.sh' to decide to/from which remote to pase/copy 

# TODO add clipboards as Array, e.g. files: rcb-c[-X:int] and rcb-p[-Y:int] and  

############################################################
# initialization, configuration
############################################################

THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
NOW_FILE_NAME=$(date +%Y-%m-%d_%H-%M-%S)

# set -e # abort on error
# set -x # disable debug

declare -A RCB_SERVERS
source "${THIS_DIR}/config.sh"

# RCB_FILES="~/.local/rclipboard/rcb"

############################################################
# Here are functions for manipulating remote clipboards 
############################################################


# on remote machine copy input to its clipboard file
# usage:
# echo "content" | _rc  # store from pipe
# maybe TODO: 
# _rc "content" # store as argument
_rc() {
  # TODO this may actually not work and it may be required to use 'while read' 
  [[ -d $(dirname "${RCB_FILES}") ]] || mkdir -p "${RCB_FILES}"
  RCB_FILES_C="${RCB_FILES}-c"
  [[ -f $(dirname "${RCB_FILES_C}") ]] || touch "${RCB_FILES_C}"
  cat > "${RCB_FILES_C}"
}

# on remote machine paste from its clipboard file
# usage:
# _rp # prints by default content of file ~/.local/rclipboard/rcb
_rp() {
  RCB_FILES_P="${RCB_FILES}-p"
  [[ -f "${RCB_FILES_P}" ]] && cat "${RCB_FILES_P}" || echo ""
}

# copy clipboard from local to remote
# usage: 
# _lc [SRV_LBL] # store from xclip using '_p', if [SRV_LBL] empt then used from ./rcb-last
# TODO:
# _lc <SRV_LBL> "content" # store from $2 param "content" 
# echo "content" | _lc <SRV_LBL> # store from input 
_lc() {
  THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
  [[ -f "${THIS_DIR}/config.sh" ]] && source "${THIS_DIR}/config.sh"

  [[ "${1}" == "-" || -z "${1}" ]] && SRV_LBL=$(eval "${LAST_USED_FILE}") || SRV_LBL="${1}"

  if [[ -z "${SRV_LBL}" ]] ; then
    echo "${ERR_MSG}Unknown remote server (param SRV_LBL in '_lc <SRV_LBL>'), exiting!"
    return
  fi
  set -x

  SRV_SSH=${RCB_SERVERS[${SRV_LBL}]}
  SRV_CMD="source ~/.bashrc ; echo \${RCB_FILES} "
  # set -x
  SCP_RCB_FILES=$(eval "${SRV_SSH} '${SRV_CMD}'")
  if [[ -z "${SCP_RCB_FILES}" ]]; then
    # echo "${ERR_MSG}Unknown files SCP_RCB_FILES, make sure that the variable RCB_FILES on remote server in ~/.bashrc exists and is not empty. Exiting!"
    # return
    SCP_RCB_FILES="${RCB_FILES}" # same as local
  fi
  echo "${SRV_LBL}" > "${LAST_USED_FILE}"

  SRV_CON=${SRV_SSH/ssh /} # TODO doublecheck all possibilities ...
  
  LCL_PASTE_FILE="${RCB_DATA_DIR}/${SRV_LBL}-c"
  touch ${LCL_PASTE_FILE}
  # TODO decide which imput to use, 
  # - default pipeline, 
  # - if empty ask for confirmation to use content of local clipboard (one-click 'y|o', not Enter)
  # or if [[ "${1}" == "_|l" ]] or smth like that 
  if [[ -f "${LCL_PASTE_FILE}" ]] ; then 
    _p > "${LCL_PASTE_FILE}"
    scp "${LCL_PASTE_FILE}" "${SRV_CON}":"${SCP_RCB_FILES}-p" 
  fi
  set +x
}

# copies clipboard from remote to local
# usage:
# _lp <SRV_LBL> # copies content of remote clipboard to local machine and prints it
_lp() {
  THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
  [[ -f "${THIS_DIR}/config.sh" ]] && source "${THIS_DIR}/config.sh"
  
  if [[ -z "${1}" ]]; then
    echo "${ERR_MSG}Missing server label, exiting!"
    return
  fi

  if [[ "${1}" == "-" ]]; then
    echo "TODO: Using last"
    return
  fi

  SRV_LBL="${1}"
  SRV_SSH=${RCB_SERVERS[${SRV_LBL}]}
  # SRV_CMD="grep RCB_FILES ~/.bashrc "
  SRV_CMD="source ~/.bashrc ; echo \${RCB_FILES}"
  # set -x
  SCP_RCB_FILES=$(eval "${SRV_SSH} '${SRV_CMD}'")
  if [[ -z "${CMD_SCP_RCB}" ]]; then
    # echo "${ERR_MSG}Unknown file CMD_SCP_RCB, make sure that variable RCB_FILRCB_FILESE on remote server in ~/.bashrc exists and is not empty"
    # return
    SCP_RCB_FILES="${RCB_FILES}" # same as on client
  fi
  SRV_CON=${SRV_SSH/ssh /} # TODO doublecheck all possibilities ...

  LCL_PASTE_FILE="${RCB_DATA_DIR}/${SRV_LBL}-p"
  if [[ -f ${LCL_PASTE_FILE} ]] ; then 
    scp "${SRV_CON}":"${SCP_RCB_FILE}-c" "${LCL_PASTE_FILE}"
    cat "${LCL_PASTE_FILE}" | _c
  fi
  # set +x
}

############################################################
# Here are functions for manipulating local clipboard
############################################################
# copy to clipboard
# Usage:
# echo "content" | _c
_c() {
  cat | xclip -r -selection clipboard
}

# copy from pipeline to clipboard and echo..
# there was a problem when chaining some pipes with their buffer when using '_c' 
# and nothing simple helped except this,
# it is more memory consuming than _c because output is stored as tmp variable
# Usage:
# echo "content" | _c
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
# Usage:
# _p # prints content of clipboard
_p() {
  xclip -selection clipboard -o
}

set +x
#
