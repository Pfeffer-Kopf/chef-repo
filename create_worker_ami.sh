#!/bin/bash
# Youappi.com
# Roman Kournajev
# Worker Image creation script 

source ~/.bashrc


rm -f deploy.log

NOW=$(date +"%d-%m--%H-%M")
VERSION=$(mysql deploy -e "SELECT version FROM releases ORDER BY release_time DESC LIMIT 1" --column-names=false | awk '{print $1}')
TEMPLATE_AMI=$(mysql deploy -e "SELECT ami_id FROM template_ami ORDER BY registration_time DESC LIMIT 1" --column-names=false | awk '{print $1}')
TEMPLATE_NAME="worker-$NOW--$VERSION"

if [ "$TEMPLATE_AMI" != "" ]
then
	echo "##teamcity[progressMessage 'Creating new intance from template AMI:$TEMPLATE_AMI with version number $VERSION']"
	bundle exec knife ec2 server create -G PH2-SG-Tomix -I $TEMPLATE_AMI -F m1.small -x ubuntu -N $TEMPLATE_NAME -r "role[worker]"  | tee deploy.log 
fi

SUCCESS=$(tail -22 deploy.log | grep 'Chef Client finished' | awk '{print $1}')

echo "$SUCCESS"
if [ "$SUCCESS" != "" ]
then
	INSTANCE_ID=$(tail -19 deploy.log | grep 'Instance' | awk '{print $3}')
	echo
	echo creating $INSTANCE_ID
	TEMPLATE_NAME="tomix--$NOW--$VERSION"
	echo creating ami : $TEMPLATE_NAME from instance ID : $INSTANCE_ID
	IMAGE_ID=$(ec2-create-image $INSTANCE_ID -n $TEMPLATE_NAME | awk '{print $2}')
	echo
	echo registering AMI ID $IMAGE_ID in mysql table deploy.worker_ami
	
	mysql deploy -e "INSERT INTO worker_ami (ami_id,ami_name,release_id) VALUES('$IMAGE_ID','$TEMPLATE_NAME','$VERSION')"
	echo "##teamcity[buildStatus status='SUCCESS' text='{build.status.text} : registered new worker AMI NAME ID : $TEMPLATE_NAME']"
	#bundle exec knife client delete $TEMPLATE_AMI
	#bundle exec knife node delete $TEMPLATE_AMI
	exit 0
else
	
	echo "##teamcity[buildStatus status='FAILURE' text='{build.status.text} : failed to create a new tomix AMI']"
	exit 1
fi
