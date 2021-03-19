#Ansible / AWS


adding to s3 bucket:

Getting AWS Canonical User ID:  aws s3api list-buckets --output text


%aws kms create-key --description some/description
... response ...
{
    "KeyMetadata": {
        "Origin": "AWS_KMS", 
        "KeyId": "", 
        "Description": "", 
        "KeyManager": "CUSTOMER", 
        "Enabled": true, 
        "KeyUsage": "ENCRYPT_DECRYPT", 
        "KeyState": "Enabled", 
        "CreationDate": 1565969477.658, 
        "Arn": "arn:aws:kms:us-east-1:......", 
        "AWSAccountId": "...."
    }
}

Use the keyId when putting to the bucket.
--sse-kms-key-id

put to a bucket:
aws s3 cp local s3://.../rpms/filename --sse-kms-key-id <kmskeyid> --sse aws:kms

list contents of a bucket:
aws s3 ls s3://..../rpms/ --summarize 

delete from a bucket:
aws s3 rm s3://..../rpms/assetname


