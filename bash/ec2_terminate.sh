#!/bin/bash

INSTANCE_ID=""

while getopts "i:" opt; do
  case ${opt} in
    i ) # instanceId
      INSTANCE_ID=$OPTARG
      echo "Using InstanceId: $INSTANCE_ID"
      ;;
   \? ) echo "Usage: cmd -i <instanceId>"
      ;;
  esac
done


function cleanup() {
  echo ${1//[$'\"\t\r\n ']}
}

function showInstanceState() {
  aws ec2 describe-instances --instance-ids $1 > /tmp/current_nodes.json
  state=`cat /tmp/current_nodes.json | jq ".Reservations[].Instances[] | select(.InstanceId==\"$1\") | .State.Name"`
  state=`cleanup $state`
  echo "$state"
}


if [ "$INSTANCE_ID" == "i-0e7536bd6aa7fae4e" ]; then
  echo "Unable to delete this: i-0e7536bd6aa7fae4e"
  exit 1
else
  output=`aws ec2 terminate-instances --instance-ids $INSTANCE_ID`
  result=$?
  if [ "$result" -eq 0 ]; then
    echo "Success!"
  
    for i in {1..10}
    do
      instState=`showInstanceState $INSTANCE_ID`
      if [ "$instState" == "terminated" ]; then
        exit 0
      fi
      echo "$INSTANCE_ID: state: $instState"
      sleep 5s
    done
  else
    echo "Problem issuing termination command: $result"
  fi
fi 
