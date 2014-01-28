#!/bin/bash
# pushesh latest version to the tomix cluster
#


source ~/.bashrc


CLUSTER_NAME=$1

COUNT=$(curl -s "$ASGARD/us-east-1/cluster/show/$CLUSTER_NAME.json" | jsawk 'return this.autoScalingGroupName' | grep -o "[_a-z0-9-]*" | wc -l )

if [ "$COUNT" -ne 2 ]
   then 
	 echo "##teamcity[buildStatus status='FAILURE' text='{build.status.text} : Will not delete ASG since the expected amount of asgs in CLUSTER is 2 and was $COUNT]"
	exit 1
   else
	ASG=$(curl -s "$ASGARD/us-east-1/cluster/show/$CLUSTER_NAME.json" | jsawk 'return this.autoScalingGroupName' | grep -o "[_a-z0-9-]*" | awk 'NR==1' )
	curl -d "name=$ASG" "$ASGARD/us-east-1/cluster/delete"
	echo "##teamcity[buildStatus status='SUCCESS' text='{build.status.text} : Deleted ASG $ASG']"
	
fi
