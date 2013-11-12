#!/bin/bash
# Youappi.com
# Roman Kournajev
# Master Broker 

source ~/.bashrc


BASE_AMI=ami-6b2c7702
ZONE=us-east-1a
bundle exec knife ec2 server create -G EC2-Broker -I $BASE_AMI --flavor m1.large  -x ubuntu  -r "role[broker]" -Z $ZONE

