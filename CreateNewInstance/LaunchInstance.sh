#!/bin/bash

INSTALL_FUSION=0
IDENTITY_FILE=0
SECURITY_GROUP_NAME=0
USERNAME=0
VOLUME_SIZE=0
DATE=$(date +%y%m%d%R:%S)
DATA_SOURCES=0
CLUSTER_SIZE=0
FUSION_LICENSE=""
TWIGKIT_CREDENTIALS=""

#options
options=$(getopt -o a:c:d:fg:hi:l:r:s:t:u: --long access-key:,cluster-size:,datasource-quantity:,install-fusion,security-groupname:,region-name:,secret-key:,twigkit-credentials:,help,identity:,fusion-license:,username: -- "$@")
[ $? -eq 0 ] || {
    echo "exiting"
    exit 1
}
eval set -- "$options"
while true; do
    case $1 in
            -a  | --access-key)
                if [[ $2 == -* ]]; then
                    missing_argument=${2}
                fi
                AWS_ACCESS_KEY=${2}
                shift 2
                ;;
            -c  | --cluster-size)
                if [[ $2 == -* ]]; then
                    missing_argument=${2}
                fi
                CLUSTER_SIZE=${2}
                shift 2
                ;;
            -d  | --datasource-quantity)
                if [[ $2 == -* ]]; then
                    missing_argument=${2}
                fi
                DATA_SOURCES=${2}
                shift 2
                ;;
            -f  | --install-fusion)
                INSTALL_FUSION=1
                shift 1
                ;;
            -g  | --security-groupname)
                if [[ $2 == -* ]]; then
                    missing_argument=${2}
                fi
                SECURITY_GROUP_NAME=${2}
                shift 2
                ;;
            -h  | --help)
                cat ./README
                exit 1
                ;;
            -i  | --identity)
                if [[ $2 == -* ]]; then
                    missing_argument=${2}
                fi
                IDENTITY_FILE=${2}
                shift 2
                ;;
            -l  | --fusion-license)
                FUSION_LICENSE=${2}
                shift 2
                ;;
            -r  | --region-name)
                if [[ $2 == -* ]]; then
                    missing_argument=${2}
                fi
                REGION=${2}
                shift 2
                ;;
            -s  | --secret-key)
                if [[ $2 == -* ]]; then
                    missing_argument=${2}
                fi
                AWS_SECRET_KEY=${2}
                shift 2
                ;;
            -t  | --twigkit-credentials)
                if [[ $2 == -* ]]; then
                    missing_argument=${2}
                fi
                TWIGKIT_CREDENTIALS=${2}
                shift 2
                ;;
            -u  | --username)
                if [[ $2 == -* ]]; then
                    missing_argument=${2}
                fi
                USERNAME=${2}
                shift 2
                ;;
            -v  | --volume-size)
                if [[ $2 == -* ]]; then
                    missing_argument=${2}
                fi
                VOLUME_SIZE=${2}
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

if [ ${SECURITY_GROUP_NAME} == 0 ]; then
    if [ ${INSTALL_FUSION} == 1 ]; then
    SECURITY_GROUP_NAME="AutoLaunchedFusionInstance${DATE}"
    else
        SECURITY_GROUP_NAME="AutoLaunchedInstance${DATE}"
    fi
fi

if [ ${IDENTITY_FILE} == 0 ]; then
    IDENTITY_FILE="${SECURITY_GROUP_NAME}"
fi

if [ ${USERNAME} == 0 ]; then
    USERNAME="ubuntu"
fi

if [ ${VOLUME_SIZE} == 0 ]; then
    VOLUME_SIZE=32
fi

if [ ${TWIGKIT_CREDENTIALS} == "" ]; then
    echo "please use -t to set the destination of the gradle settings.xml file"
    exit 1;
fi

if [ ${FUSION_LICENSE} == "" ]; then
    echo "please use -l to set the destination of the license.properties file"
    exit 1;
fi
##########################################################################################
#Check prerequisites
##########################################################################################
#check for awscli, and install it if missing
if ! type "aws" > /dev/null; then
    echo "installing aws api"
    pip install awscli --upgrade --user
else
    echo "aws api already installed"
fi

#check for awscli auth


##########################################################################################
#Check for security group and create it if it does not exist.
##########################################################################################
echo "Creating security group"
SECURITY_GROUP_ID=$(aws ec2 create-security-group --group-name ${SECURITY_GROUP_NAME} --description "security group for automatically created instance: ${DATE}")

echo "Authorizing security group:"
PUBLIC_IP=`curl https://ipinfo.io/ip`
aws ec2 authorize-security-group-ingress --group-name ${SECURITY_GROUP_NAME} --protocol tcp --port 22 --cidr "${PUBLIC_IP}/32"
echo ""

##########################################################################################
#Check for key pair and create it if it does not exist.
##########################################################################################
if [ ! -f ~/.ssh/${IDENTITY_FILE}.pem ]; then
    echo "Creating key pair"
    aws ec2 create-key-pair --key-name "${IDENTITY_FILE}" --query 'KeyMaterial' --output text > ~/.ssh/${IDENTITY_FILE}.pem
    chmod 400 ~/.ssh/${IDENTITY_FILE}.pem
else
    echo "Key pair of that name already exists."
fi
echo ""
echo ""

##########################################################################################
#Launch desired ec2 instance
##########################################################################################
if [[ ${CLUSTER_SIZE} > 1 ]]; then
    INSTANCE_ID=$(aws ec2 run-instances --image-id ami-ba602bc2  --security-group-ids "${SECURITY_GROUP_ID:18:20}" --count ${CLUSTER_SIZE} --instance-type t2.xlarge --key-name "${IDENTITY_FILE}" --tag-specifications 'ResourceType=instance,Tags=[{Key=cluster,Value=fusion}]')
    echo "Instance ID: $(aws ec2 describe-instance-status --filters 'Name=tag:cluster,Values=fusion')"
    echo "Security Group ID: ${SECURITY_GROUP_ID:18:20}"
else
    INSTANCE_ID=$(aws ec2 run-instances --image-id ami-ba602bc2  --security-group-ids "${SECURITY_GROUP_ID:18:20}" --count 1 --instance-type t2.xlarge --key-name "${IDENTITY_FILE}" --query 'Instances[0].InstanceId')
    INSTANCE_ID="${INSTANCE_ID:1:19}"
    echo "Instance ID: ${INSTANCE_ID}"
    echo "Security Group ID: ${SECURITY_GROUP_ID:18:20}"
fi


#test if instance is running
if [[ ${CLUSTER_SIZE} > 1 ]]; then
TESTVAR=$(aws ec2 describe-instance-status --filters 'Name=tag:cluster,Values=fusion' | grep passed)
COUNTER=0
echo "Starting instance (this might take a while)"
echo -n "Initializing"

while [ "${TESTVAR}" == "" ]; do
        echo -n "."
        sleep 1
        COUNTER=$(($COUNTER + 1))
        TESTVAR=$(aws ec2 describe-instance-status --instance-id "${INSTANCE_ID}" | grep passed)
    done
else
TESTVAR=$(aws ec2 describe-instance-status --instance-ids "${INSTANCE_ID}" | grep passed)
COUNTER=0
echo "Starting instance (this might take a while)"
echo -n "Initializing"

    while [ "${TESTVAR}" == "" ]; do
        echo -n "."
        sleep 1
        COUNTER=$(($COUNTER + 1))
        TESTVAR=$(aws ec2 describe-instance-status --instance-id "${INSTANCE_ID}" | grep passed)
    done
fi

echo ""
echo "Startup completed(${COUNTER}s)"
echo ""
echo ""

#########################################################################################
#SSH/Install Fusion on ec2 instance
#########################################################################################
PUBLIC_DNS=$(aws ec2 describe-instances --instance-ids ${INSTANCE_ID} --query 'Reservations[0].Instances[0].PublicDnsName')
PUBLIC_DNS="${PUBLIC_DNS%\"}"
PUBLIC_DNS="${PUBLIC_DNS#\"}"
SSH_HOSTNAME="${PUBLIC_DNS}"
echo -n "checking connection to the server: "
SSH_COUNTER=0
SSH_TEST=$(ssh -o "StrictHostKeyChecking no" -i "~/.ssh/${IDENTITY_FILE}.pem" "${USERNAME}@${PUBLIC_DNS}"  echo "ok")
echo "${HOSTNAME}"

#check for ssh connection, will time out after a minute
while [[ ${SSH_TEST} != "ok" ]]; do
    if [ ${SSH_COUNTER} == 60 ]; then
        echo ""
        echo "It appears that its taking longer to connect to the server than usual, check if the server is running and try again."
        exit 1
    fi
    if [[ $(echo "${SSH_TEST}" | grep "publickey") != "" ]]; then
        echo "The server seems to think that ${IDENTITY_FILE}.pem is public, check local permissions of the file and contents before trying again"
        exit 1
    fi
    echo -n "."
    sleep 1
    SSH_COUNTER=$((${SSH_COUNTER} + 1))
done
echo ""
echo "Connected(${SSH_COUNTER}s)"

##########################################################################################
#Modify instance size
##########################################################################################
VOLUME_ID=$(aws ec2 describe-instances --instance-ids "${INSTANCE_ID}" --query 'Reservations[0].Instances[0].BlockDeviceMappings[0].Ebs.VolumeId')
VOLUME_ID="${VOLUME_ID%\"}"
VOLUME_ID="${VOLUME_ID#\"}"
aws ec2 modify-volume --volume-id ${VOLUME_ID} --size ${VOLUME_SIZE} --volume-type io1 --iops 100
while [[ $(ssh -Y -i "~/.ssh/${IDENTITY_FILE}.pem" "${USERNAME}@${PUBLIC_DNS}"  "lsblk --json | grep xvda1 | grep ${VOLUME_SIZE}G") == "" ]]; do
    ssh -Y -i "~/.ssh/${IDENTITY_FILE}.pem" "${USERNAME}@${PUBLIC_DNS}"  "sudo growpart /dev/xvda 1"
    sleep 10
done
ssh -Y -i "~/.ssh/${IDENTITY_FILE}.pem" "${USERNAME}@${PUBLIC_DNS}"  "sudo resize2fs /dev/xvda1"

##########################################################################################
#Decide to install fusion or ssh into the box
##########################################################################################
if [ "${INSTALL_FUSION}" == 1 ]; then
    echo "Starting Fusion install with SearchHub"
    ./FusionInstaller/InstallFusion.sh -i ~/.ssh/${IDENTITY_FILE}.pem -u ${USERNAME} -H ${SSH_HOSTNAME} -d ${DATA_SOURCES} -t ${TWIGKIT_CREDENTIALS} -l ${FUSION_LICENSE}
else
    ssh -Y -i ~/.ssh/${IDENTITY_FILE}.pem "${USERNAME}@${SSH_HOSTNAME}"
fi