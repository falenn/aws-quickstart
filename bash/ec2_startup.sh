#!/bin/bash

EC2_FILE="NOTSET"
USER_DATA_FILE="NOTSET"
groupId="NOTSET"

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

while getopts "g:d:c:t:s:k:p:" opt; do
  case ${opt} in
    g ) # groupId
      groupId=$OPTARG
      echo "Using groupId $groupId"
      ;;
    d ) # process user-data path
      USER_DATA_FILE=$OPTARG
      echo "User-data filepath: $USER_DATA_FILE"
      ;;
    c )
      EC2_FILE=$OPTARG
      echo "Using this ec2 template: $EC2_FILE"
      ;;
    t)
      TAGS=$OPTARG
      echo "Using tag: $TAGS"
      ;;
    s)
      SUBNET_ID=$OPTARG
      echo "Using SUBNET_ID: $SUBNET_ID"
      ;;
    k) KEY_NAME=$OPTARG
      echo "SSH Key: $KEY_NAME"
      ;;
    p) INSTANCE_PROFILE=$OPTARG
      echo "Instance profile: $INSTANCE_PROFILE"
     ;;
    \? ) echo "Usage: cmd -g <groupId> -d <path/to/your/user-data.txt> -s <SID> -c <path/to/ec2-template.json>"
      ;;
  esac
done

if [ "$TAGS" == "NOTSET" ]; then
  echo "TAGS not set.  -t <tags> [{Key=..,Values=..},..]"
  exit 1
elif [ "$groupId" == "NOTSET" ]; then
  echo "groupId not set. -g <groupId>"
  exit 1
elif [ "$EC2_FILE" == "NOTSET" ]; then
  echo "ec2-template not set. -c <ec2-template.json> - see examples/ec2-skeleton.json"
  exit 1
elif [ "$USER_DATA_FILE" == "NOTSET" ]; then
  echo "user-data.txt not set. -d <user-data.txt> - see examples/user-data.txt"
  exit 1
elif [ "$SUBNET_ID" == "NOTSET" ]; then
  echo "Set the subnet id -s <subnet-id>"
  exit 1
fi


aws ec2 run-instances \
    --count 1 \
    --subnet $SUBNET_ID \
    --image-id `getLatestCentOSImageId.sh` \
    --security-group-ids $groupId \
    --cli-input-json file://$EC2_FILE  \
    --key-name $KEY_NAME \
    --user-data file://$USER_DATA_FILE > /tmp/resultsfile.json \
    --tag-specifications "ResourceType=instance,Tags=$TAGS" "ResourceType=volume,Tags=$TAGS" \
    --block-device-mappings "[{\"DeviceName\":\"/dev/sda1\", 
          \"Ebs\":{\"VolumeSize\": 20, 
          \"DeleteOnTermination\": true}}]"

if [[ $? -eq 0 ]]; then 
  instanceId=`cat /tmp/resultsfile.json | jq -r '.Instances[0].InstanceId'`
  ipaddr=`cat /tmp/resultsfile.json | jq -r '.Instances[0].NetworkInterfaces[0].PrivateIpAddresses[0].PrivateIpAddress'`

  echo "InstanceId: $instanceId"
  
  # check every 10s for status change
  while true; do
    aws ec2 describe-instances --instance-ids $instanceId > /tmp/resultsfile.json
    state=`cat /tmp/resultsfile.json | jq '.Reservations | .[] | .Instances | .[0].State.Code'`
    echo "state: $state"
    if [[ $state -eq 16 ]]; then
      break;
    else
      echo "Waiting..."
      sleep 10s
    fi
  done
  
  #Work to do after VM in running state
  aws ec2 associate-iam-instance-profile \
    --iam-instance-profile Name=$INSTANCE_PROFILE \
    --instance-id $instanceId

  # Make sure root EBS deletes on termination
#  cat << EOF > /tmp/nopersist-mapping.json
#[{"DeviceName": "/dev/sda1", "Ebs": { "DeleteOnTermination":true }}]
#EOF
#  aws ec2 modify-instance-attribute --instance-id $instanceId --block-device-mappings file:///tmp/nopersist-mapping.json

  #aws ec2 modify-instance-attribute --instance-id $instanceId --groups $groupId
  echo "Debug user-data startup script here: /var/log/cloud-init-output.log"
  echo "ssh devuser@$ipaddr"

  # ping $ipaddr
else 
  echo "Issues in instance creation"
fi
