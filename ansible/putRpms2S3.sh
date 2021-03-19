#!/bin/bash
bucket=$1
dir=$2
kms-key-id=$3

if [[ "$bucket" == "" ]]; then
  echo "Bucket $1 cannot be empty"
  exit 1
fi

if [[ "$dir" == "" ]]; then
  echo "Dir $2 cannot be empty"
  exit 1
fi

for filename in $dir/*.rpm; do
    echo "Putting to s3 bucket $bucket rpms/$(basename $filename)"
    #aws s3 cp mydata.txt s3://mybucket/ --sse-kms-key-id mykeyid --sse aws:kms

    aws s3 cp $filename s3://$bucket/rpms/$(basename $filename) \
	--sse-kms-key-id $kms-key-id \
        --sse aws:kms 
done
