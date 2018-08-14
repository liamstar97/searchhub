#!/bin/bash

echo "Uploading config files"
echo "Installer home:"${INSTALLER_HOME}
echo "Fusion home:"${FUSION_HOME}
echo "SearchHub home:"${SEARCHHUB_HOME}
echo "Username:"${USERNAME}
echo "Hostname:"${SSH_HOSTNAME}
echo "Identity:"${IDENTITY_FILE}

scp -i ${IDENTITY_FILE} ${INSTALLER_HOME}/scripts/FusionInstaller.sh ${USERNAME}@${SSH_HOSTNAME}:
scp -i ${IDENTITY_FILE} ${INSTALLER_HOME}/conf/fusion.properties ${USERNAME}@${SSH_HOSTNAME}:
scp -i ${IDENTITY_FILE} ${INSTALLER_HOME}/conf/myenv.sh.tmpl ${USERNAME}@${SSH_HOSTNAME}:
scp -i ${IDENTITY_FILE} ${INSTALLER_HOME}/conf/password_file.json.tmpl ${USERNAME}@${SSH_HOSTNAME}:
echo "Upload complete"
echo ""