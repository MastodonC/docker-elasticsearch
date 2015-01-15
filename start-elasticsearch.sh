#!/bin/bash

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

echo "DATA_DIRS is ${DATA_DIRS}"

sed -i \
    -e "s@#path.plugins: .*@path.plugins: ${DATA_DIR}/plugins@" \
    -e "s@#path.data: .*@path.data: ${DATA_DIRS}/data@" \
    -e "s@#path.logs: .*@path.logs: ${LOG_DIR}/log@" \
    -e "s@#path.work: .*@path.work: ${DATA_DIR}/work@" \
    /elasticsearch/config/elasticsearch.yml

/elasticsearch/bin/elasticsearch
