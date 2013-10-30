#
# Cookbook Name:: youappi-base
# Recipe:: default
#
# Copyright 2013, YouAPPI Ltd.
#
# All rights reserved - Do Not Redistribute
#



include_recipe "aws"

server_name = ENV['SERVER_NAME'] 
aws = data_bag_item("aws", "main")

aws_resource_tag node['ec2']['instance_id']  do
  aws_access_key aws['aws_access_key_id']
  aws_secret_access_key aws['aws_secret_access_key']
  tags({"Name" => "#{server_name}"})
  action :add
end

