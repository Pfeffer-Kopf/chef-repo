#
# Cookbook Name:: youappi-base
# Recipe:: default
#
# Copyright 2013, YouAPPI Ltd.
#
# All rights reserved - Do Not Redistribute
#

#include_recipe "route53"

ENV['ROLE'] = 'MGN'
ENV['ENV'] = 'stg'

aws = data_bag_item('aws', 'main')

#route53_record "create a record" do
#  name  "mgnstg"
#  value node['ec2']['public-hostname']
#  type  "CNAME"

#  zone_id               aws['route_53_zone_id']
#  aws_access_key_id     aws['aws_access_key_id']
#  aws_secret_access_key aws['aws_secret_access_key']

<<<<<<< HEAD
#  action :create
#end
=======
  action :update
end
>>>>>>> 946d68fc4b3e5add28d0b820a3feffa729d725f8

