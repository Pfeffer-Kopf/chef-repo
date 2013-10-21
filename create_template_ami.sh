#!/bin/bash
# Youappi.com
# Roman Kournajev
# Master Server Image creation script 

source ~/.bashrc


rm -f deploy.log
NOW=$(date +"%d-%m-%Y_%H-%M")
VERSION=$(bundle exec knife cookbook  list | grep youappi | awk '{print $2}')
BASE_AMI=ami-dfebbab6
echo "##teamcity[progressMessage 'Creating new intance from youappi-base cookbook version $VERSION']"
bundle exec knife ec2 server create -G PH2-SG-Tomix -I $BASE_AMI -F m1.small -x ubuntu -S youappi-PH2  -N template-tomix-$NOW -r "role[tomix]" | tee deploy.log 

SUCCESS=$(tail -22 deploy.log | grep 'Chef Client finished' | awk '{print $1}')
EMPTY=""
INSTANCE_ID=""
TEMPLATE_NAME=""

echo "$SUCCESS"
if [ "$SUCCESS" != "$EMPTY" ]
then
	INSTANCE_ID=$(tail -19 deploy.log | grep 'Instance' | awk '{print $3}')
	echo
	echo creating $INSTANCE_ID
	TEMPLATE_NAME="server-tempate-$NOW"
	echo creating ami : $TEMPLATE_NAME from instance ID : $INSTANCE_ID
	IMAGE_ID=$(ec2-create-image $INSTANCE_ID -n "server-template-$NOW"|awk '{print $2}')
	echo
	echo registering AMI in mysql table deploy.template_ami 
	mysql deploy -e "INSERT INTO template_ami (ami_id,ami_name,cookbook_version) VALUES('$IMAGE_ID','$TEMPLATE_NAME','$VERSION')"
	echo "##teamcity[buildStatus status='SUCCESS' text='{build.status.text} : registered new AMI NAME : $TEMPLATE_NAME with ID $IMAGE_ID']"
	exit 0
else
	
	echo "##teamcity[buildStatus status='FAILURE' text='{build.status.text} : failed to create a new server AMI']"
	exit 1
fi
