#!/bin/bash

# requires jq for json parsing in bash.
# yum install -y jq

IMAGE_NAME="'CentOS*'"

while getopts "i:" opt; do
  case ${opt} in
    i) # image name
      IMAGE_NAME=$OPTARG
      ;;
    \?)  echo "Usage: -i <image name>"
      exit 1
      ;;
  esac
done

CMD="aws ec2 describe-images \
    --filters Name=architecture,Values='x86_64' \
    --filters Name='name',Values=$IMAGE_NAME"

ImageJSON="`$CMD`"

imageId=`echo $ImageJSON | jq '.Images[].ImageId'`

# Remove quotes
temp="${imageId%\"}"
temp="${temp#\"}"
echo "$temp"
