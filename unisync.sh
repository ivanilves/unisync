#!/bin/bash
#
# Unison wrapper to synchronize certain subdirs in the
# specified directory between two workstations/servers.
# Based on Unison: http://www.cis.upenn.edu/~bcpierce/unison

function suicide() {
  echo "${@}"
  exit 1
}

function separator() {
  echo "--------------------------------------------------------------------------------"
}

if [ ${#} -lt 2 ]; then
  suicide "Usage: $(basename ${0}) CONFIG_FILE SUBDIR1 [SUBDIR2 ... SUBDIRn]"
fi

CONFIG_FILE="${1}"; shift
if [ -f  "${CONFIG_FILE}" ]; then
  . "${CONFIG_FILE}"
else
  suicide "Unable to open config: ${CONFIG_FILE}"
fi

if [ ! $(which unison) ]; then
  suicide "Unison executable not found :("
fi

LOCAL_IP_ADDRESSES=$(ip addr | egrep "^\s*inet6? " | awk '{print $2}')
if [ $(echo "${LOCAL_IP_ADDRESSES}" | egrep "${LAN_IP_ADDRESS_MATCH}" | wc -l) -ne 0 ]; then
  REMOTE_ADDRESS=${LAN_ADDRESS}
  REMOTE_PORT=${LAN_PORT}
else
  REMOTE_ADDRESS=${WAN_ADDRESS}
  REMOTE_PORT=${WAN_PORT}
fi

echo
echo "[ ${REMOTE_ADDRESS}:${REMOTE_PORT} ]"
echo
for SUBDIR in ${@}; do
  SUBDIR_PATH="${HOME}/${SUBDIR}"
  LOCAL_SUBDIR_PATH="file:///${SUBDIR_PATH}"
  REMOTE_SUBDIR_PATH="ssh://${USER}@${REMOTE_ADDRESS}/${SUBDIR_PATH}"
  UNISON_OPTS="-batch -terse -owner -group -times -links true -sshargs -oPort=${REMOTE_PORT}"

  separator
  echo "* Syncing: ${SUBDIR_PATH}"
  separator

  unison ${UNISON_OPTS} "${LOCAL_SUBDIR_PATH}" "${REMOTE_SUBDIR_PATH}"
  echo
done

read -n1 -r -p "Press any key to continue..." key
