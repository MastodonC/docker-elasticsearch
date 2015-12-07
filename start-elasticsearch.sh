#!/bin/bash

CONFIG_FILE=/elasticsearch/config/elasticsearch.yml

CLUSTER_NAME=${ELASTICSEARCH_CLUSTER_NAME:-kixi}

LOG_DIR="/logs/elasticsearch/${HOSTNAME}"
mkdir -p "${LOG_DIR}"

DIR_TAIL="elasticsearch"

function join { local IFS="$1"; shift; echo "$*"; }

if [ -z "${DATA_DIR_PATTERN}" ] ; then
    DATA_DIRS="/data/${DIR_TAIL}"
    mkdir -p ${DATA_DIRS}
else
    ddirs=()
    candidates=(${DATA_DIR_PATTERN})
    for dir in ${candidates[@]}
    do
	thedir="$(pwd)${dir}/${DIR_TAIL}"
	mkdir -p ${thedir}
	ddirs+=("${thedir}")
    done
    DATA_DIRS=$(join , ${ddirs[@]})
fi

echo "CLUSTER_NAME is ${CLUSTER_NAME}"
echo "DATA_DIRS is ${DATA_DIRS}"

# FIXME: DATA_DIRS is really only allowed to be a single dir.

mkdir -p ${DATA_DIRS}/{plugins,data,log,work}

chown -R elasticsearch:elasticsearch ${DATA_DIRS}
chown -R elasticsearch:elasticsearch ${LOG_DIR}


cat <<EOF > ${CONFIG_FILE}
cluster.name: ${CLUSTER_NAME}
path.plugins: ${DATA_DIRS}/plugins
path.data: ${DATA_DIRS}/data
path.logs: ${LOG_DIR}
path.work: ${DATA_DIRS}/work

# TODO - confirm security implications...
http.cors.allow-origin: "/.*/"
http.cors.enabled: true
EOF

/usr/bin/sudo -u elasticsearch /elasticsearch/bin/elasticsearch
