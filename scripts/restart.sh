#!/bin/bash
set -u
set -e

MESSAGE="Usage: restart CURRENT_HOST_IP"
if ( [ $# -ne 1 ] ); then
    echo "$MESSAGE"
    exit
fi

CONSTELLATION_NODES=$(cat ../data/constellation-nodes.json)
STATIC_NODES=$(cat ../data/static-nodes.json)
CURRENT_HOST_IP="$1"
PWD="$HOME"

generate_conf() {
   #define parameters which are passed in.
   NODE_IP="$1"
   CONSTELLATION_PORT="$2"
   OTHER_NODES="$3"
   PWD="$4"

   #define the template.
   cat  << EOF
# Externally accessible URL for this node (this is what's advertised)
url = "http://$NODE_IP:$CONSTELLATION_PORT/"

# Port to listen on for the public API
port = $CONSTELLATION_PORT

# Socket file to use for the private API / IPC
socket = "$PWD/alastria/data/constellation/constellation.ipc"

# Initial (not necessarily complete) list of other nodes in the network.
# Constellation will automatically connect to other nodes not in this list
# that are advertised by the nodes below, thus these can be considered the
# "boot nodes."
othernodes = $OTHER_NODES

# The set of public keys this node will host
publickeys = ["$PWD/alastria/data/constellation/keystore/node.pub"]

# The corresponding set of private keys
privatekeys = ["$PWD/alastria/data/constellation/keystore/node.key"]

# Optional file containing the passwords to unlock the given privatekeys
# (one password per line -- add an empty line if one key isn't locked.)
passwords = "$PWD/alastria/data/passwords.txt"

# Where to store payloads and related information
storage = "$PWD/alastria/data/constellation/data"

# Verbosity level (each level includes all prior levels)
#   - 0: Only fatal errors
#   - 1: Warnings
#   - 2: Informational messages
#   - 3: Debug messages
verbosity = 2

EOF
}

cp ~/alastria-node/data/static-nodes.json ~/alastria/data/static-nodes.json
generate_conf "${CURRENT_HOST_IP}" "9000" "$CONSTELLATION_NODES" "${PWD}" > ~/alastria/data/constellation/constellation.conf

~/alastria-node/scripts/start.sh

set +u
set +e