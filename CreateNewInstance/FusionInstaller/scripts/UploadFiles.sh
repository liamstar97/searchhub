#!/bin/bash

echo "Uploading config files"
echo "Fusion home:"${FUSION_HOME}
echo "SearchHub home:"${SEARCHHUB_HOME}
echo "Username:"${USERNAME}
echo "Hostname:"${SSH_HOSTNAME}
echo "Identity:"${IDENTITY_FILE}
echo "license.properties:" ${FUSION_LICENSE}
echo "settings.xml:" ${TWIGKIT_CREDENTIALS}
echo ""

scp -i ${IDENTITY_FILE} ${INSTALLER_HOME}/scripts/FusionInstaller.sh ${USERNAME}@${SSH_HOSTNAME}:
scp -i ${IDENTITY_FILE} ${INSTALLER_HOME}/scripts/IndexSearchHubDatasources.sh ${USERNAME}@${SSH_HOSTNAME}:
scp -i ${IDENTITY_FILE} ${INSTALLER_HOME}/conf/fusion.properties ${USERNAME}@${SSH_HOSTNAME}:
scp -i ${IDENTITY_FILE} ${INSTALLER_HOME}/conf/myenv.sh.tmpl ${USERNAME}@${SSH_HOSTNAME}:
scp -i ${IDENTITY_FILE} ${INSTALLER_HOME}/conf/password_file.json.tmpl ${USERNAME}@${SSH_HOSTNAME}:


#THIS MUST GET FIXED AND REMOVED!(TODO: move mv and mkdir to FusionInstaller + add options)
scp -i ${IDENTITY_FILE} ${FUSION_LICENSE} ${USERNAME}@${SSH_HOSTNAME}:
ssh -i "${IDENTITY_FILE}" "${USERNAME}@${SSH_HOSTNAME}"  mkdir "~/.fusion"
ssh -i "${IDENTITY_FILE}" "${USERNAME}@${SSH_HOSTNAME}"  mv "license.properties" "~/.fusion"
scp -i ${IDENTITY_FILE} ${TWIGKIT_CREDENTIALS} ${USERNAME}@${SSH_HOSTNAME}:
ssh -i "${IDENTITY_FILE}" "${USERNAME}@${SSH_HOSTNAME}"  mkdir "~/.m2"
ssh -i "${IDENTITY_FILE}" "${USERNAME}@${SSH_HOSTNAME}"  mv "settings.xml" "~/.m2"

echo "Upload complete"
echo ""