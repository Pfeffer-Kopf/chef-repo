#!/bin/bash
# Youappi.com
# Roman Kournajev
# Worker Image creation script 

source ~/.bashrc

rm -f deploy.log

NOW=$(date +"%d-%m--%H-%M")
VERSION=$3
BRANCH=$2
TEMPLATE_AMI=$(mysql deploy -e "SELECT ami_id FROM template_ami ORDER BY registration_time DESC LIMIT 1" --column-names=false | awk '{print $1}')
TEMPLATE_NAME="worker-$NOW--$VERSION"
PARAMS='{"release":"'$VERSION'","branch":"'$BRANCH'"}'

if [ "$TEMPLATE_AMI" != "" ]
then
	echo "##teamcity[progressMessage 'Creating new intance from template AMI:$TEMPLATE_AMI with version number $VERSION from branch $2']"
	bundle exec knife ec2 server create -G PH2-SG-Tomix -I ${TEMPLATE_AMI} -F m1.small -x ubuntu -j ${PARAMS} -N ${TEMPLATE_NAME} -r "role[worker]"  | tee deploy.log
fi

SUCCESS=$(tail -23 deploy.log | grep 'Chef Client finished' | awk '{print $1}')

echo "$SUCCESS"
if [ "$SUCCESS" != "" ]
then
	INSTANCE_ID=$(tail -19 deploy.log | grep 'Instance' | awk '{print $3}')
	echo
	echo creating ${INSTANCE_ID}
	echo creating ami : ${TEMPLATE_NAME} from instance ID : ${INSTANCE_ID}
	IMAGE_ID=$(ec2-create-image ${INSTANCE_ID} -n ${TEMPLATE_NAME} | awk '{print $2}')
	echo
	echo registering AMI ID ${IMAGE_ID} in mysql table deploy.worker_ami
	
	mysql deploy -e "INSERT INTO worker_ami (ami_id,ami_name,release_id) VALUES('$IMAGE_ID','$TEMPLATE_NAME','$VERSION')"
        
        if [ "$1" == "delete" ]
	then 
		echo "##teamcity[progressMessage 'Sleeping 2min before terminating instance $INSTANCE_ID']"
		sleep 2m
		bundle exec knife ec2 server delete ${INSTANCE_ID} -y
	fi
      
	if [ "$IMAGE_ID" != "" ]
	then 
	        echo "##teamcity[buildStatus status='SUCCESS' text='{build.status.text} : registered new AMI name : $TEMPLATE_NAME , ID : $IMAGE_ID branch : $2']"
		exit 0
	else
		
	        echo "##teamcity[buildStatus status='FAILED' text='{build.status.text} : Could not create AMI from isntance ]"
		exit 1
	fi
else
	
	echo "##teamcity[buildStatus status='FAILURE' text='{build.status.text} : failed to create a new tomix AMI']"
	exit 1
fi
