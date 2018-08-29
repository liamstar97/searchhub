#!/bin/bash

#USERNUM=2
#
#FINISHED_INDEXING=0
#INDEXER_STATUS="FINISHED"
DATA_SOURCES=0

#options
options=$(getopt -o d: --long datasource-quantity -- "$@")
[ $? -eq 0 ] || {
    echo "exiting"
    exit 1
}
eval set -- "$options"
while true; do
    case $1 in
            -d  | --datasource-list)
                if [[ $2 == -* ]]; then
                    missing_argument=${2}
                fi
                DATA_SOURCES=${2}
                shift 2
                ;;
            --)
                shift
                break
                ;;
    esac
done

if [ "${missing_argument}" != "" ]; then
    echo "${missing_argument} requires an argument please use -h or --help"
    exit 1
fi

IFS=',' read -r -a array <<< "${DATA_SOURCES}"

for DATA_SOURCE in "${array[@]}"
do
    echo "curl -u admin:password123 -X  POST http://localhost:8764/api/apollo/connectors/jobs/${DATA_SOURCE}"
    curl -u admin:password123 -X  POST http://localhost:8764/api/apollo/connectors/jobs/${DATA_SOURCE}
done

