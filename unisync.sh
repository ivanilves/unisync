#!/bin/bash
#
# unisync (WIP)
#
# TODO:
# * Separate config (look in many locations)
# * Better help/usage info
# * terse?
# * Better README
# * Better description
# * Moar checks?
# * Desktop launcher!
# * unison link and credits!
#
SYNC_ROOT=${HOME}
LAN_ADDRESS=192.168.24.1
LAN_PORT=22
LAN_IP_ADDRESS_MATCH="^192\.168\.24\."
WAN_ADDRESS=212.83.137.21
WAN_PORT=2200

if [ ${#} -lt 1 ]; then
  echo "Usage: $(basename ${0}) SUBDIR1 SUBDIR2 ... SUBDIRn"
  exit 1
fi

LOCAL_IP_ADDRESSES=$(ip addr | egrep "^\s*inet6? " | awk '{print $2}')
if [ $(echo "${LOCAL_IP_ADDRESSES}" | egrep "${LAN_IP_ADDRESS_MATCH}" | wc -l) -ne 0 ]; then
  REMOTE_ADDRESS=${LAN_ADDRESS}
  REMOTE_PORT=${LAN_PORT}
else
  REMOTE_ADDRESS=${WAN_ADDRESS}
  REMOTE_PORT=${WAN_PORT}
fi

echo "[ ${REMOTE_ADDRESS}:${REMOTE_PORT} ]"
for SUBDIR in ${@}; do
  SUBDIR_PATH="${HOME}/${SUBDIR}"
  LOCAL_SUBDIR_PATH="file:///${SUBDIR_PATH}"
  REMOTE_SUBDIR_PATH="ssh://${USER}@${REMOTE_ADDRESS}/${SUBDIR_PATH}"
  UNISON_OPTS="-batch -owner -group -times -links true -force newer -sshargs -oPort=${REMOTE_PORT}"

  echo "* Syncing: ${SUBDIR_PATH}"
  unison ${UNISON_OPTS} "${LOCAL_SUBDIR_PATH}" "${REMOTE_SUBDIR_PATH}"
done
