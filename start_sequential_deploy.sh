#!/bin/bash
# pushesh latest version to the tomix cluster
#


source ~/.bashrc

GROUP=$1
CLUSTER_NAME=$2
BRANCH=$3

AMI_ID=$(mysql deploy -e "SELECT ami_id FROM worker_ami WHERE branch='$BRANCH' ORDER BY registration_time DESC LIMIT 1" --column-names=false | awk '{print $1}')
VERSION=$(mysql deploy -e "SELECT release_id FROM worker_ami WHERE branch='$BRANCH' ORDER BY registration_time DESC LIMIT 1" --column-names=false | awk '{print $1}')
ASG_NAME=$(curl -s $ASGARD/us-east-1/cluster/show/tomix_cluster_stg.json | jsawk 'return this.autoScalingGroupName' | grep -o "[_a-z0-9-]*")

echo "##teamcity[progressMessage 'Starting creation of next ASG on CLUSTER $CLUSTER_NAME  with $AMI_ID with version $VERSION from $BRANCH']"

if [ -z "$AMI_ID" ] ; then
	exit 1
	else
	sleep 5

	curl -d "name=$CLUSTER_NAME&imageId=$AMI_ID&trafficAllowed=true&checkHealth=true" "$ASGARD/us-east-1/cluster/createNextGroup"
	
	sleep 1m
	
	ASG_NEW=$(curl -s $ASGARD/us-east-1/cluster/show/tomix_cluster_stg.json | jsawk 'return this.autoScalingGroupName' | grep -o "[_a-z0-9-]*" | awk 'NR==2')

	echo "##teamcity[progressMessage 'Created new ASG $ASG_NEW , waiting for instnaces to become healthy before stopping traffic on $ASG_NAME']"

	COUNTER=0
	while [  $COUNTER -lt 10 ]; do
             let COUNTER=COUNTER+1 
	     sleep 30
             DNS=$(curl -s "$ASGARD/us-east-1/autoScaling/anyInstance/$ASG_NEW?field=publicDnsName")
             
	     STATUS=$(curl --connect-timeout 5 -IL "$DNS/health" |  grep "HTTP" | awk '{print $2}')
	     if [ "$STATUS" == '200' ]
		then 
			echo "##teamcity[progressMessage 'Instance $DNS , responded 200 to health check , switching off traffic on $ASG_NAME']"
			let COUNTER=10
             fi

         done
	sleep 5
	curl -d "name=$ASG_NAME" "$ASGARD/us-east-1/cluster/deactivate"
	echo "##teamcity[buildStatus status='SUCCESS' text='{build.status.text} : Created new ASG $ASG_NEW version $VERSION with $AMI_ID, switched off traffic on old ASG $ASG_NAME']"
fi
