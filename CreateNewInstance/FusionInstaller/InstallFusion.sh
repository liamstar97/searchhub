#!/bin/bash

INSTALLER_HOME="$(dirname -- "${BASH_SOURCE-$0}")"
USERNAME=ubuntu
DATA_SOURCES=0
TWIGKIT_CREDENTIALS=""
FUSION_LICENSE=""


fusion_home_set=0
searchhub_home_set=0
username_set=0
hostname_set=0

if [ $# == 0 ]; then
    echo "missing options, please use -h or --help to see all available options"
    exit 1
fi

function print_usage() {
    ERROR_MSG="$1"

    if [ "$ERROR_MSG" != "" ]; then
        echo -e "\nERROR: $ERROR_MSG\n"
    fi

    echo
    cat ${INSTALLER_HOME}/README
}

#options
if [ $# -gt 0 ]; then
    while true; do
        case "$1" in
            -d|--datasource-quantity)
                if [[ -z "$2" || "${2:0:1}" == "-" ]]; then
                    print_usage "a list of datasources is required when using the $1 option!"
                    exit 1
                fi
                DATA_SOURCES=${2}
                shift 2
            ;;
            -f|--fusion_home)
                if [[ -z "$2" || "${2:0:1}" == "-" ]]; then
                    print_usage "path for fusion home is required when using the $1 option!"
                    exit 1
                fi
                FUSION_HOME=${2}
                fusion_home_set=1
                shift 2
            ;;
            -h|--help)
                cat ${INSTALLER_HOME}/README
                exit 1
            ;;
            -H|--hostname)
                if [[ -z "$2" || "${2:0:1}" == "-" ]]; then
                    print_usage "hostname is required when using the $1 option!"
                    exit 1
                fi
                SSH_HOSTNAME=${2}
                hostname_set=1
                shift 2
            ;;
            -l|--fusion-license)
                if [[ -z "$2" || "${2:0:1}" == "-" ]]; then
                    print_usage "path to license.properties is required when using the $1 option!"
                    exit 1
                fi
                shift 2
            ;;
            -i|--identity)
                if [[ -z "$2" || "${2:0:1}" == "-" ]]; then
                    print_usage "ssh identity is required when using the $1 option!"
                    exit 1
                fi
                IDENTITY_FILE=${2}
                shift 2
            ;;
            -s|--searchhub_home)
                if [[ -z "$2" || "${2:0:1}" == "-" ]]; then
                    print_usage "path for searchhub home is required when using the $1 option!"
                    exit 1
                fi
                SEARCHHUB_HOME=${2}
                searchhub_home_set=1
                shift 2
            ;;
            -t|--twigkit-credentials)
                if [[ -z "$2" || "${2:0:1}" == "-" ]]; then
                    print_usage "path to settings.xml is required when using the $1 option!"
                    exit 1
                fi
                TWIGKIT_CREDENTIALS=${2}
                shift 2
            ;;
            -u|--username)
                if [[ -z "$2" || "${2:0:1}" == "-" ]]; then
                    print_usage "username is required when using the $1 option!"
                    exit 1
                fi
                USERNAME=${2}
                username_set=1
                shift 2
            ;;
            *)
                if [ "$1" != "" ]; then
                    PASS_THRU_ARGS+=("$1")
                    shift
                else
                    break
              fi
            ;;
        esac
    done
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

echo ${TWIGKIT_CREDENTIALS}
echo ${FUSION_LICENSE}

#exports vars and runs UploadFiles.sh
. ${INSTALLER_HOME}/scripts/UploadFiles.sh
ssh -i ${IDENTITY_FILE} ${USERNAME}@${SSH_HOSTNAME} "export USERNAME=${USERNAME}; export FUSION_HOME=${FUSION_HOME}; export SEARCHHUB_HOME=${SEARCHHUB_HOME}; export DATA_SOURCES=${DATA_SOURCES}; ./FusionInstaller.sh"
