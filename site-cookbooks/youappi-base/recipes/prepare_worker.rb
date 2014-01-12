#
# Cookbook Name:: youappi-base
# Recipe:: default
#
# Copyright 2013, YouAPPI Ltd.
#
# All rights reserved - Do Not Redistribute
#


include_recipe 'aws'

service 'tomcat7' do
  action :stop
end

service 'collectd' do
  action :stop
end

aws = data_bag_item('aws', 'main')
appName = node['appName']

aws_s3_file "/var/lib/tomcat7/webapps/#{appName}.war" do
  bucket "deploy.youappi.com"
  remote_path "releases/#{node['branch']}/#{node['release']}/#{appName}.war"
  aws_access_key_id aws['aws_access_key_id']
  aws_secret_access_key aws['aws_secret_access_key']
end

directory '/var/lib/tomcat7/webapps/ROOT' do
  action :delete
  recursive true
end

service 'collectd' do
  action [:disable]
end

service 'tomcat7' do
  action [:disable]
end


directory '/youappi/logs' do
  owner 'tomcat7'
  group 'tomcat7'
  action :create
end
