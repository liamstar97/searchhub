#!/bin/bash

echo "Uploading config files"
echo ${INSTALLER_HOME}
echo ${FUSION_HOME}
echo ${SEARCHHUB_HOME}
echo ${USERNAME}
echo ${SSH_HOSTNAME}
echo ${IDENTITY_FILE}

scp -i ${IDENTITY_FILE} ${INSTALLER_HOME}/scripts/FusionInstaller.sh ${USERNAME}@${SSH_HOSTNAME}:
scp -i ${IDENTITY_FILE} ${INSTALLER_HOME}/conf/fusion.properties ${USERNAME}@${SSH_HOSTNAME}:
scp -i ${IDENTITY_FILE} ${INSTALLER_HOME}/conf/myenv.sh.tmpl ${USERNAME}@${SSH_HOSTNAME}:
scp -i ${IDENTITY_FILE} ${INSTALLER_HOME}/conf/password_file.json.tmpl ${USERNAME}@${SSH_HOSTNAME}:
echo "Upload complete"
echo ""