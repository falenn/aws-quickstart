#!/bin/bash

TAG=""
declare -a SERVERS=()

while getopts "t:" opt; do
  case ${opt} in
    t)  # tag
      TAG=$OPTARG
      ;;
    \?)
      echo "Usage: cmd -t <tag>"
      exit 1
      ;;
   esac
done

function cleanup() {
  echo ${1//[$'\"\t\r\n ']}
}

# Show my nodes
if [ ! -z "$TAG" ]; then 
  echo "Querying with a filter: \"Name=tag:Name, Values=$TAG\""
  aws ec2 describe-instances --filters "Name=tag:Name,Values=$TAG" > /tmp/current_nodes.json
else
  aws ec2 describe-instances > /tmp/current_nodes.json
fi

i=0
instances=`cat /tmp/current_nodes.json | jq -r '.Reservations[].Instances[].InstanceId'`
for instance in ${instances[@]}; do
  instance=`cleanup $instance`
  serverIp=`cat /tmp/current_nodes.json | jq ".Reservations[].Instances[] | select(.InstanceId==\"$instance\") | .PrivateIpAddress"`
  serverIp=`cleanup $serverIp`
  state=`cat /tmp/current_nodes.json | jq ".Reservations[].Instances[] | select(.InstanceId==\"$instance\") | .State.Name"`
  state=`cleanup $state`
  tags=`cat /tmp/current_nodes.json | jq ".Reservations[].Instances[] | select(.InstanceId==\"$instance\") | .Tags"`
  tags=${tags//[$'\r\n\\[\]\{\}\"\t\r\n ']}
  SERVERS[i]="$instance,$serverIp,$state,Tags[$tags]"  
  ((i++))
done

echo "InstanceId		IP		State	Tags"
echo "------------------------------------------------------------------------------------------"
for s in ${SERVERS[@]}; do
  s=`echo $s | tr ',' '	'`
  echo "$s"
done
