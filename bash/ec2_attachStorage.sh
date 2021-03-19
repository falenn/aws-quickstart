#!/bin/bash

#getopts take in instanceId, size of storage, tags, and mount point in instance

EC2_INSTANCE_ID="NOTSET"
STORAGE_SIZE="100"
MOUNT_PATH="/data"
TAG="NOTSET"
DEBUG="true"
REGION="us-east-1"
AVAILABILITY_ZONE="us-east-1a"
VOLUME_TYPE=gp2
MOUNT_DEVICE=/dev/sdf

while getopts "i:s:m:t:s" opt; do
  case ${opt} in
    i)
      EC2_INSTANCE_ID=$OPTARG
      if [ "$DEBUG" == "true" ]; then 
        echo "EC2 instanceId: $EC2_INSTANCE_ID"
      fi
      ;;
    s)
      STORAGE_SIZE=$OPTARG
      if [ "$DEBUG" == "true" ]; then
        echo "Storage Size: $STORAGE_SIZE"
      fi
      ;;
    m)
      MOUNT_PATH=$OPTARG
      if [ "$DEBUG" == "true" ]; then
        echo "Mount: $MOUNT_PATH"
      fi
      ;;
    t)
      TAG=$OPTARG
      if [ "$DEBUG" == "true" ]; then
        echo "Tag: $TAG"
      fi
      ;;
    \?)
      echo "Usage: cmd -i <instanceId> -t <tag> [-s <storageSize>|100GB -m <mountPath>|/data]" 
      exit 1
      ;;
  esac
done

if [ "$EC2_INSTANCE_ID" == "NOTSET" ]; then
  echo "Usage: cmd -i <instanceId> -t <tag> [-s <storageSize>|100GB -m <mountPath>|/data]"
  exit 1
elif [ "$TAG" == "NOTSET" ]; then
  echo "Usage: cmd -i <instanceId> -t <tag> [-s <storageSize>|100GB -m <mountPath>|/data]"
  exit 1
fi

# cmd to run to create
aws ec2 create-volume \
  --size $STORAGE_SIZE \
  --region $REGION \
  --availability-zone $AVAILABILITY_ZONE \
  --tag-specifications "ResourceType=volume,Tags=[{Key=Name,Value=$TAG}]" \
  --volume-type $VOLUME_TYPE > storageResult.json

if [ "$?" == 0 ]; then
  echo "Storage creation submission successfull"
  
  volumeId=`cat /tmp/storageResult.json | jq -r '.VolumeId'`
  echo "VolumeId: $VolumeId"

# now, get the volume-id from the result (json) which looks like this:
#{
#    "AvailabilityZone": "us-east-1a",
#    "Attachments": [],
#    "Tags": [],
#    "VolumeType": "gp2",
#    "VolumeId": "vol-1234567890abcdef0",
#    "State": "creating",
#    "SnapshotId": null,
#    "CreateTime": "YYYY-MM-DDTHH:MM:SS.000Z",
#    "Size": 80
#}


# Cmd to run to attach
  echo "Attaching Volume: $volumeId to instance: $EC2_INSTANCE_ID at mount: $MOUNT_PATH"
aws ec2 attach-volume \
  --volume-id $volumeId \
  --instance-id $EC2_INSTANCE_ID \
  --device $MOUNT_DEVICE > /tmp/mountResult.json

# Now get attach status from json which looks like this:
#{
#    "AvailabilityZone": "us-east-1a",
#    "Attachments": [],
#    "Tags": [],
#    "VolumeType": "io1",
#    "VolumeId": "vol-1234567890abcdef0",
#    "State": "creating",
#    "Iops": 1000,
#    "SnapshotId": "snap-066877671789bd71b",
#    "CreateTime": "YYYY-MM-DDTHH:MM:SS.000Z",
#    "Size": 500
#}

  mountState=`cat /tmp/mountResult.json | jq -r '.State'`
  echo "Mount state: $mountState"
fi


