#!/bin/bash

INSTALLER_HOME=$(pwd)
USERNAME=ubuntu

#Checks for options, exits if none are used
if [ $# == 0 ]; then
    echo "missing options, please use -h to see all available options"
    exit 1
fi

fusion_home_set=0
searchhub_home_set=0
username_set=0
hostname_set=0

#executes options
options=$(getopt -o f:hH:i:s:u: -- "$@")
[ $? -eq 0 ] || {
    echo "exiting"
    exit 1
}
eval set -- "$options"
while true; do
    case $1 in
        -f)
            echo "Setting Fusion install directory to: ${2}"
            FUSION_HOME=${2}
            fusion_home_set=1
            shift 2
            ;;
        -h)
            cat ./README.txt
            exit 1
            ;;
        -H)
            echo "Setting hostname to: ${2}"
            SSH_HOSTNAME=${2}
            hostname_set=1
            shift 2
            ;;
        -i)
            IDENTITY_FILE=${2}
            shift 2
            ;;
        -s)
            echo "Setting searchhub install directory to: ${2}"
            SEARCHHUB_HOME=${2}
            searchhub_home_set=1
            shift 2
            ;;
        -u)
            echo "Username set to: ${2}"
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

if [ "$USERNAME" != "" ]; then
    FUSION_HOME=/home/${USERNAME}/${FUSION_HOME}
fi

if [ ${fusion_home_set} == 0 ]; then
    FUSION_HOME=/home/${USERNAME}/fusion
    echo "Setting Fusion home to: ${FUSION_HOME}"
fi

if [ ${searchhub_home_set} == 0 ]; then
    SEARCHHUB_HOME=/home/${USERNAME}/src/lucidworks/searchhub
    echo "Setting SearchHub home to: ${SEARCHHUB_HOME}"
fi

#exports vars and runs UploadFiles.sh
. ${INSTALLER_HOME}/scripts/UploadFiles.sh
ssh -i ${IDENTITY_FILE} ${USERNAME}@${SSH_HOSTNAME} "export FUSION_HOME=${FUSION_HOME}; export SEARCHHUB_HOME=${SEARCHHUB_HOME}; ./FusionInstaller.sh"