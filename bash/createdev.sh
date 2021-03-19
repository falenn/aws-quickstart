#!/bin/bash
#
# Helper script for spinning up a simple EC2 instance using user-data and aws json
#

if [ -f '~/.aws/vars' ]; then 
  source ~/.aws/vars
else
  echo "No ~/.aws/vars to load!  A template has been created for you in ~/.aws/vars."
  
cat << EOF > ~/.aws/vars
  # Private vars for EC2 instance creation

  #name of the ec2 instance
  hostname=${USER}-dev

  # tag to add to EC2 instance and associated dependencies for easier identificatoin
  NAME_TAG=${USER}

  #script to call upon 1st boot 
  USER_DATA="~/.aws/user-data.txt"

  # AWS config to use to create the instance
  EC2_CONFIG="~/.aws/ec2-java-dev.json"
  #
  SECURITY_GROUP_ID=

  #
  VPC_ID=

  #
  SUBNET_ID=
  
  #
  IAM_ROLE=
  
  # 
  INSTANCE_PROFILE=

  # ssh key to use
  SSH_KEY_NAME=
EOF
  exit 1
fi

# Build the tags
TAGS="[{Key=Name,Value=${hostname}},{Key=user,Value=${NAME_TAG}},{Key=project,Value=EHPC_RM},{Key=nostartup,Value=true}]"

# call the real script - which is assumed to be on the path
ec2_startup.sh \
	-g $SECURITY_GROUP_ID \
	-d $USER_DATA \
	-c $EC2_CONFIG \
	-t $TAGS \
	-s $SUBNET_ID \
	-k $SSH_KEY_NAME \
	-p $INSTANCE_PROFILE \


