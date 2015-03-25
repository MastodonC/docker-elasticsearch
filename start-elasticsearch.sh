#!/bin/bash

CONFIG_FILE=/elasticsearch/config/elasticsearch.yml

CLUSTER_NAME=${ELASTICSEARCH_CLUSTER_NAME?NOT DEFINED}

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


cat <<EOF > ${CONFIG_FILE}
cluster.name: ${CLUSTER_NAME}
path.plugins: ${DATA_DIR}/plugins
path.data: ${DATA_DIRS}/data
path.logs: ${LOG_DIR}/log
path.work: ${DATA_DIR}/work

# TODO - confirm security implications...
http.cors.allow-origin: "/.*/"
http.cors.enabled: true
EOF

/elasticsearch/bin/elasticsearch
