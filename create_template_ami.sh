#!/bin/bash
# Youappi.com
# Roman Kournajev
# Master Server Image creation script 

source ~/.bashrc


rm -f deploy.log
NOW=$(date +"%d-%m--%H-%M")
VERSION=$(bundle exec knife cookbook  list | grep youappi | awk '{print $2}')
BASE_AMI=ami-6b2c7702
TEMPLATE_NAME="worker-template-$NOW"
echo "##teamcity[progressMessage 'Creating new intance from youappi-base cookbook version $VERSION']"
bundle exec knife ec2 server create -G PH2-SG-Tomix -I ${BASE_AMI} -F m1.small -x ubuntu -N ${TEMPLATE_NAME} -r "role[template]" | tee deploy.log

SUCCESS=$(tail -22 deploy.log | grep 'Chef Client finished' | awk '{print $1}')
EMPTY=""
INSTANCE_ID=""

echo "$SUCCESS"
if [ "$SUCCESS" != "$EMPTY" ]
then
	echo	
	echo Deleting client.pem file from /etc/chef on the target instance
	bundle exec knife ssh 'name:worker-template*' 'sudo rm /etc/chef/client.pem' -x ubuntu
	INSTANCE_ID=$(tail -19 deploy.log | grep 'Instance' | awk '{print $3}')
	echo
	echo creating ${INSTANCE_ID}
	echo creating ami : ${TEMPLATE_NAME} from instance ID : ${INSTANCE_ID}
	IMAGE_ID=$(ec2-create-image ${INSTANCE_ID} -n ${TEMPLATE_NAME}|awk '{print $2}')
	echo
	echo registering AMI in mysql table deploy.template_ami 
	mysql deploy -e "INSERT INTO template_ami (ami_id,ami_name,cookbook_version) VALUES('$IMAGE_ID','$TEMPLATE_NAME','$VERSION')"

	echo "##teamcity[progressMessage 'Sleeeping 2 min before deleting instance $INSTANCE_ID']"
	sleep 2m
        bundle exec knife ec2 server delete ${INSTANCE_ID} -P --node-name ${TEMPLATE_NAME} -y
        echo "##teamcity[buildStatus status='SUCCESS' text='{build.status.text} : registered new AMI NAME : $TEMPLATE_NAME with ID $IMAGE_ID']"
	exit 0
else
	
	echo "##teamcity[buildStatus status='FAILURE' text='{build.status.text} : failed to create a new server AMI']"
	exit 1
fi
