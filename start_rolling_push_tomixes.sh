#!/bin/bash
# pushesh latest version to the tomix cluster
#


source ~/.bashrc

AMI_ID=$(mysql deploy -e "SELECT ami_id FROM worker_ami ORDER BY registration_time DESC LIMIT 1" --column-names=false | awk '{print $1}')
VERSION=$(mysql deploy -e "SELECT release_id FROM worker_ami ORDER BY registration_time DESC LIMIT 1" --column-names=false | awk '{print $1}')
INSTANCE_COUNT=$(curl -s "$ASGARD/us-east-1/autoScaling/show/tomix_cluster.json" | jsawk 'return this.instanceCount')

echo "##teamcity[progressMessage 'Pushing $AMI_ID into tomix cluster with version $VERSION , replacing $INSTANCE_COUNT isntances']"


if [ -z "$AMI_ID" ]
then
	exit 1
else
	CONCURRENT=2
	if [ "$INSTANCE_COUNT" == "2" ]
	then
	    CONCURRENT=1
	fi
	echo ${CONCURRENT}
	curl -d "name=tomix_cluster&appName=tomix_cluster&imageId=$AMI_ID&instanceType=m1.medium&keyName=youappi-PH2&selectedSecurityGroups=PH2-SG-Tomix&relaunchCount=${INSTANCE_COUNT}&concurrentRelaunches=${CONCURRENT}&newestFirst=false&afterBootWait=150" "$ASGARD/us-east-1/push/startRolling"
	echo "##teamcity[buildStatus status='SUCCESS' text='{build.status.text} : Initialized rolling push of version $VERSION with $AMI_ID , replacing $INSTANCE_COUNT , concurrently replacing $CONCURRENT']"
fi



