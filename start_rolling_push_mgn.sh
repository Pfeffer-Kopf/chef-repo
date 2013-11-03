#!/bin/bash
# pushesh latest version to the tomix cluster
#


source ~/.bashrc

AMI_ID=$(mysql deploy -e "SELECT ami_id FROM worker_ami ORDER BY registration_time DESC LIMIT 1" --column-names=false | awk '{print $1}')
VERSION=$(mysql deploy -e "SELECT release_id FROM worker_ami ORDER BY registration_time DESC LIMIT 1" --column-names=false | awk '{print $1}')
MGN_DNS=$(curl -s "$ASGARD/us-east-1/autoScaling/anyInstance/mgn_instnace?field=publicDnsName")

echo "##teamcity[progressMessage 'Pushing $AMI_ID into tomix cluster with version $VERSION , replacing 1 isntance']"



if [ -z "$AMI_ID" ]
then
	exit 1
else
	sleep 5
	echo "##teamcity[progressMessage 'Stopping message comsumption of MGN before redeploy']"
	curl "$MGN_DNS/mgn/stopMessageConsumption"
	sleep 1m

	curl -d "name=mgn_instnace&appName=mgn_instance&imageId=$AMI_ID&instanceType=m1.medium&keyName=youappi-PH2&selectedSecurityGroups=PH2-SG-Management&relaunchCount=1&concurrentRelaunches=1&newestFirst=false&afterBootWait=30" "$ASGARD/us-east-1/push/startRolling"
	echo "##teamcity[buildStatus status='SUCCESS' text='{build.status.text} : Initialized rolling push of MGG instnace version $VERSION with $AMI_ID , replacing 1 instance']"
fi



