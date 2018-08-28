#!/bin/bash

#USERNUM=2
#
#FINISHED_INDEXING=0
#INDEXER_STATUS="FINISHED"
DATA_SOURCES=${DATA_SOURCES}

#options
options=$(getopt -o d: --long datasource-quantity -- "$@")
[ $? -eq 0 ] || {
    echo "exiting"
    exit 1
}
eval set -- "$options"
while true; do
    case $1 in
            -d  | --datasource-quantity)
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

#if [ ${DATA_SOURCES} == 0 ]; then
#    echo "number of data sources to be indexed is zero, please choose data sources you would like to index from the Fusion Admin page, or"
#    echo "using IndexSearchHubDatasources.sh on the servers home directory"
#    exit 1
#fi

#Run indexer on a few mailing lists
#while [[ ${FINISHED_INDEXING} != ${USERNUM} ]]; do
#    if [[ ${INDEXER_STATUS} != "RUNNING" || $(curl -u admin:password123 -X  GET http://localhost:8764/api/apollo/connectors/jobs/mailing-list-accumulo-accumulo-dev | grep FINISHED) != "FINISHED" ]]; then
#        curl -u admin:password123 -X  POST http://localhost:8764/api/apollo/connectors/jobs/mailing-list-accumulo-accumulo-dev
#        sleep 15
#        INDEXER_STATUS=$(curl -u admin:password123 -X  GET http://localhost:8764/api/apollo/connectors/jobs/mailing-list-accumulo-accumulo-dev | grep RUNNING)
#        FINISHED_INDEXING=$(($FINISHED_INDEXING + 1))
#    fi
#    if [[ ${INDEXER_STATUS} != "RUNNING" || $(curl -u admin:password123 -X  GET http://localhost:8764/api/apollo/connectors/jobs/mailing-list-accumulo-accumulo-user | grep FINISHED) != "FINISHED" ]]; then
#        curl -u admin:password123 -X  POST http://localhost:8764/api/apollo/connectors/jobs/mailing-list-accumulo-accumulo-user
#        sleep 15
#        INDEXER_STATUS=$(curl -u admin:password123 -X  GET http://localhost:8764/api/apollo/connectors/jobs/mailing-list-accumulo-accumulo-user | grep RUNNING)
#        FINISHED_INDEXING=$(($FINISHED_INDEXING + 1))
#    fi
#done

curl -u admin:password123 -X  POST http://localhost:8764/api/apollo/connectors/jobs/mailing-list-accumulo-accumulo-dev
curl -u admin:password123 -X  POST http://localhost:8764/api/apollo/connectors/jobs/mailing-list-accumulo-accumulo-user

