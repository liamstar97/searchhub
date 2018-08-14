#!/bin/bash
echo "post ssh"

FUSION_HOME=${FUSION_HOME}/4.1.0

echo ${INSTALLER_HOME}
echo ${FUSION_HOME}
echo ${SEARCHHUB_HOME}


echo "Downloading and installing additional required packages"
sudo apt-get -qq update
sudo apt-get -y -qq install gradle
sudo apt-get -y -qq install maven
sudo apt-get -y -qq install scala
sudo apt-get -y -qq install default-jre
echo ""
echo ""

echo "Stopping Fusion services"
${FUSION_HOME}/bin/fusion stop
echo ""
echo ""

echo "Removing old Fusion install"
rm -r $FUSION_HOME
echo ""
echo ""

echo "Extracting Fusion 4.1.0"
tar -C /home/ubuntu/ -x -f ./fusion-4.1.0.tar.gz
echo ""
echo ""

echo "Editing config files"
mv fusion.properties $FUSION_HOME/conf
echo ""
echo ""

echo "launching Fusion"
${FUSION_HOME}/bin/fusion start
echo ""
echo ""

echo "Removing old SearchHub install"
rm -r searchhub
echo ""
echo ""

echo "Downloading SearchHub"
mkdir -p $SEARCHHUB_HOME
cd $SEARCHHUB_HOME
git clone https://github.com/lucidworks/searchhub.git
SEARCHHUB_HOME=${SEARCHHUB_HOME}/searchhub
cd $SEARCHHUB_HOME
git fetch origin
git checkout -t origin/4_1_upgrade
echo ""
echo ""

echo "Moving SearchHub config files"
mv ~/myenv.sh.tmpl myenv.sh
mv ~/password_file.json.tmpl password_file.json
source myenv.sh
echo ""
echo ""

echo "Installing SearchHub"
./gradlew deployLibs --stacktrace
${FUSION_HOME}/bin/api restart
${FUSION_HOME}/bin/connectors restart
./install.sh
echo ""
echo ""

echo "Done!"