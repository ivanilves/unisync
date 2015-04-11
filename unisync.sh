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

if [ ! $(which unison) ]; then
  suicide "Unison executable not found :("
fi

CONFIG_FILE="${HOME}/.unisync.config"
if [ ! -f  "${CONFIG_FILE}" ]; then
  suicide "Unable to open config: ${CONFIG_FILE}"
fi
. "${CONFIG_FILE}"

if [ "$(echo ${1} | egrep "^(--help|-h)$")" ]; then
  echo "Usage: $(basename ${0}) [SUBDIR1 SUBDIR2 ... SUBDIRn]"
  exit 0
fi

LOCAL_IP_ADDRESSES=$(ip addr | egrep "^\s*inet6? " | awk '{print $2}')
if [ $(echo "${LOCAL_IP_ADDRESSES}" | egrep "${LAN_IP_ADDRESS_MATCH}" | wc -l) -ne 0 ]; then
  REMOTE_ADDRESS=${LAN_ADDRESS}
  REMOTE_PORT=${LAN_PORT}
else
  REMOTE_ADDRESS=${WAN_ADDRESS}
  REMOTE_PORT=${WAN_PORT}
fi

BATCH_MODE=0
if [ ${#} -gt 0 ]; then
  SYNC_SUBDIRS=${@}
  BATCH_MODE=1
fi

echo
echo "[ ${REMOTE_ADDRESS}:${REMOTE_PORT} ]"
echo
for SYNC_SUBDIR in ${SYNC_SUBDIRS}; do
  SYNC_SUBDIR_PATH="${SYNC_ROOT}/${SYNC_SUBDIR}"
  LOCAL_SUBDIR_PATH="file:///${SYNC_SUBDIR_PATH}"
  REMOTE_SUBDIR_PATH="ssh://${USER}@${REMOTE_ADDRESS}/${SYNC_SUBDIR_PATH}"
  UNISON_OPTS="-batch -terse -owner -group -times -links true -sshargs -oPort=${REMOTE_PORT}"

  separator
  echo "* Syncing: ${SYNC_SUBDIR_PATH}"
  separator

  unison ${UNISON_OPTS} "${LOCAL_SUBDIR_PATH}" "${REMOTE_SUBDIR_PATH}"
  echo
done

test ${BATCH_MODE} -eq 0 && read -n1 -r -p "Press any key to continue..."
