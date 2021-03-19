! AWS Automation - AWS-kickstart

This is a simple set of bash scripts to help automate the construction of ec-2 

! Setup
1. Clone this project somewhere
2. Get your groupId
3. Create your SSH Certs
4. Edit user-data.txt to include your certs
4.1. The user-data.txt file does have a field for password.
5. Edit the ec2-skeleton.json to add your sid 

! Usage
Run aws_startup.sh -g <groupid> to create a new ec-2 instance.

The script performs a sequence of functions:
* The script uses the 'getLatestCentOSImageId.sh' script to get the latest centos AMI id to use to build our target image.
* The script injects user-data at ec2 creation (this is what lets you log in with your cert)
* Uses ec2-skeleton.json file as the template for building the ec2 instance.
 
Results from the script are written to resultsfile.json.  This file is then parsed to get the instanceId and ipaddr.

The script will print connection information for the user, then ping the box.  When the user sees a successful ping, the user should be able to connect.


