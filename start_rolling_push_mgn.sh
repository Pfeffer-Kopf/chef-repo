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
MGN_DNS=$(curl -s "$ASGARD/us-east-1/autoScaling/anyInstance/$CLUSTER_NAME?field=publicDnsName")

echo "##teamcity[progressMessage 'Replacing $AMI_ID mgn instance with version $VERSION , replacing 1 isntance']"



if [ -z "$AMI_ID" ]
then
	exit 1
else
	sleep 5
	echo "##teamcity[progressMessage 'Stopping message comsumption of MGN before redeploy']"
	curl "$MGN_DNS/mgn/stopMessageConsumption"
	sleep 1m

	curl -d "name=$CLUSTER_NAME&appName=$CLUSTER_NAME&imageId=$AMI_ID&instanceType=$SIZE&keyName=youappi-PH2&selectedSecurityGroups=$GROUP&relaunchCount=1&concurrentRelaunches=1&newestFirst=false&afterBootWait=30" "$ASGARD/us-east-1/push/startRolling"
	echo "##teamcity[buildStatus status='SUCCESS' text='{build.status.text} : Initialized rolling push of MGN instance version $VERSION with $AMI_ID , replacing 1 instance']"
fi
