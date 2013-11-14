#!/bin/bash
# Youappi.com
# Roman Kournajev
# Master Broker 

source ~/.bashrc


BASE_AMI=ami-69012400
ZONE=us-east-1a
NAME=broker-template
bundle exec knife ec2 server create -G EC2-Broker -I $BASE_AMI --flavor m1.large -N $NAME -x ubuntu  -r "recipe[youappi-base::init_broker]" -Z $ZONE

