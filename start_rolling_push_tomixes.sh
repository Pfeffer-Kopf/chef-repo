#!/bin/bash
# pushesh latest version to the tomix cluster
#


source ~/.bashrc

GROUP=$1
SIZE=$2
CLUSTER_NAME=$3
BRANCH=$4

AMI_ID=$(mysql deploy -e "SELECT ami_id FROM worker_ami WHERE branch='$BRANCH' ORDER BY registration_time DESC LIMIT 1" --column-names=false | awk '{print $1}')
VERSION=$(mysql deploy -e "SELECT release_id FROM worker_ami WHERE branch='$BRANCH' ORDER BY registration_time DESC LIMIT 1" --column-names=false | awk '{print $1}')
INSTANCE_COUNT=$(curl -s "$ASGARD/us-east-1/autoScaling/show/$CLUSTER_NAME.json" | jsawk 'return this.instanceCount')

echo "##teamcity[progressMessage 'Pushing $AMI_ID into tomix cluster with version $VERSION from $BRANCH, replacing $INSTANCE_COUNT isntances']"

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
	curl -d "name=$CLUSTER_NAME&appName=$CLUSTER_NAME&imageId=$AMI_ID&instanceType=$SIZE&keyName=youappi-PH2&selectedSecurityGroups=$GROUP&relaunchCount=${INSTANCE_COUNT}&concurrentRelaunches=${CONCURRENT}&newestFirst=false&afterBootWait=200" "$ASGARD/us-east-1/push/startRolling"
	echo "##teamcity[buildStatus status='SUCCESS' text='{build.status.text} : Initialized rolling push of version $VERSION with $AMI_ID , replacing $INSTANCE_COUNT , concurrently replacing $CONCURRENT']"
fi



