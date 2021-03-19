#!/bin/bash
#
# Helper script for spinning up a simple EC2 instance using user-data and aws json
#


hostname=dev-host
GROUP_ID="sg-<groupID>"
USER_DATA="~/.aws/user-data.txt"
EC2_CONFIG="~/.aws/ec2-java-dev.json"
NAME_TAG="<name>"
VPC="vpc-<PVC-id>"
SUBNET_ID="subnet-<subnetID>"
IAM_ROLE="arn:aws:iam::...<IAM Role>"
INSTANCE_PROFILE=<Profile name>
TAGS="[{Key=Name,Value=${hostname}},{Key=user,Value=${NAME_TAG}},{Key=project,Value=EHPC_RM},{Key=nostartup,Value=true}]"
KEY_NAME="<SSH Keypair Name>"


ec2_startup.sh \
	-g $GROUP_ID \
	-d $USER_DATA \
	-c $EC2_CONFIG \
	-t $TAGS \
	-s $SUBNET_ID \
	-k $KEY_NAME \
	-p $INSTANCE_PROFILE \


