#!/bin/bash
############################################################
# vprusa, 2021, prusa.vojtech@gmail.com
############################################################

# notes:
# CB = "clipboard"
THIS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"
# THIS_FILE="$(basename "$(test -L "$0" && readlink "$0" || echo "$0")")"
# THIS_FILE=$(basename "$0")
# set -e
# set -x
#shopt -s expand_aliases 2>/dev/null

FLAGS=""
# r - install remote
# l - install local
[[ -n "${1}" ]] && FLAGS="${1}"

[[ -f "${THIS_DIR}/config.sh" ]] || cp "${THIS_DIR}/config-sample.sh" "${THIS_DIR}/config.sh"

source ${THIS_DIR}/config.sh 

_rcb_touch() { mkdir -p "$(dirname "$1")" || return; touch "$1"; }

[[ -z "${1}" ]] && exit 0 

RCB_NAME="rclipboard"

# prepare remote clipboard
if [[ "${FLAGS}" == *"r"* ]] ; then
  echo "copyting this repo to remote "
  for SRV_LBL in "${!RCB_SERVERS[@]}"; do 
set -x
    CMD_SSH=${RCB_SERVERS[$SRV_LBL]}
    echo "$SRV_LBL - $CMD_SSH"
    $(${CMD_SSH} "mkdir -p ${RCB_FILES_REL_DIR}")
    REMOTE_RCB_FILES_DIR=$(eval "${CMD_SSH} 'realpath ${RCB_FILES_REL_DIR}'")
    # REMOTE_RCB_FILES_DIR=${CMD_SSH} "realpath ${RCB_FILES_REL_DIR}")
    # REMOTE_RCB_FILES_DIR_TMP_FILE="${THIS_DIR}/rem_abs_path"
    # ${CMD_SSH} "realpath ${RCB_FILES_REL_DIR}" > ${REMOTE_RCB_FILES_DIR_TMP_FILE}
    # REMOTE_RCB_FILES_DIR=$(eval "cat ${REMOTE_RCB_FILES_DIR_TMP_FILE}")
    # rm ${REMOTE_RCB_FILES_DIR_TMP_FILE}
    ${CMD_SSH} "mkdir ${REMOTE_RCB_FILES_DIR}"
    if [[ -z "${REMOTE_RCB_FILES_DIR}" ]] ; then
      echo "${ERR_MSG}Somethjing wen wrong and var REMOTE_RCB_FILES_DIR is empty, exiting!"
      return
    fi
    CMD_CON=${CMD_SSH/ssh /}
    $(eval "${CMD_SSH} 'mkdir ${REMOTE_RCB_FILES_DIR}'")
    # ${CMD_SSH} "mkdir ${REMOTE_RCB_FILES_DIR}"
    scp ${THIS_DIR}/install.sh ${THIS_DIR}/config-sample.sh ${THIS_DIR}/main.sh ${CMD_CON}:${REMOTE_RCB_FILES_DIR}/
    $(eval "${CMD_SSH} '${REMOTE_RCB_FILES_DIR}/install.sh l'")
set +x

    # ${CMD_SSH} "${REMOTE_RCB_FILES_DIR}/install.sh l"
  done
fi
# prepare local clipboard
if [[ "${FLAGS}" == *"l"* ]] ; then
# set -x
  [[ -f "${RCB_FILES}-c" ]] || _rcb_touch "${RCB_FILES}-c"
  [[ -f "${RCB_FILES}-p" ]] || _rcb_touch "${RCB_FILES}-p"
  # BRC_FILE=$(eval "realpath ${HOME}/.bashrc")
  BRC_FILE="${HOME}/.bashrc"
  if [[ -f "${BRC_FILE}" ]] ; then 
    if ! grep -q "${RCB_NAME}:" "${BRC_FILE}"; then
      echo -e "# ${RCB_NAME}: \nsource ${THIS_DIR}/main.sh" >> "${BRC_FILE}"
      return
    fi
  fi
fi

set +x
#
