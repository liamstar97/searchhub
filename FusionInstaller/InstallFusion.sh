#!/bin/bash

INSTALLER_HOME="$(dirname -- "${BASH_SOURCE-$0}")"
USERNAME=ubuntu

#Checks for options, exits if none are used
if [ $# == 0 ]; then
    echo "missing options, please use -h or --help to see all available options"
    exit 1
fi

fusion_home_set=0
searchhub_home_set=0
username_set=0
hostname_set=0

#executes options
options=$(getopt -o f:hH:i:s:u: --long fusion_home:,help,hostname:,identity:,searchhub_home:,username: -- "$@")
[ $? -eq 0 ] || {
    echo "exiting"
    exit 1
}
eval set -- "$options"
while true; do
    case $1 in
            -f | --fusion_home)
                if [[ $2 == -* ]]; then
                    missing_argument=${2}
                fi
                FUSION_HOME=${2}
                fusion_home_set=1
                shift 2
                ;;
            -h | --help)
                cat ./README
                exit 1
                ;;
            -H | --hostname)
                if [[ $2 == -* ]]; then
                    missing_argument=${2}
                fi
                SSH_HOSTNAME=${2}
                hostname_set=1
                shift 2
                ;;
            -i | --identity)
                if [[ $2 == -* ]]; then
                    missing_argument=${2}
                fi
                IDENTITY_FILE=${2}
                shift 2
                ;;
            -s | --searchhub_home)
                if [[ $2 == -* ]]; then
                    missing_argument=${2}
                fi
                SEARCHHUB_HOME=${2}
                searchhub_home_set=1
                shift 2
                ;;
            -u | --username)
                if [[ $2 == -* ]]; then
                    missing_argument=${2}
                fi
                USERNAME=${2}
                username_set=1
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

if [ "$USERNAME" != "" ]; then
    FUSION_HOME=/home/${USERNAME}/${FUSION_HOME}
fi

if [ ${fusion_home_set} == 0 ]; then
    FUSION_HOME=/home/${USERNAME}/fusion
fi

if [ ${searchhub_home_set} == 0 ]; then
    SEARCHHUB_HOME=/home/${USERNAME}/src/lucidworks/searchhub
fi

#exports vars and runs UploadFiles.sh
. ${INSTALLER_HOME}/scripts/UploadFiles.sh
ssh -i ${IDENTITY_FILE} ${USERNAME}@${SSH_HOSTNAME} "export USERNAME=${USERNAME}; export FUSION_HOME=${FUSION_HOME}; export SEARCHHUB_HOME=${SEARCHHUB_HOME}; ./FusionInstaller.sh"