#
# Cookbook Name:: youappi-base
# Recipe:: default
#
# Copyright 2013, YouAPPI Ltd.
#
# All rights reserved - Do Not Redistribute
#


service 'tomcat7' do
  action :stop
end

service 'collectd' do
  action :stop
end

remote_file '/var/lib/tomcat7/webapps/ROOT.war' do
  source 'https://s3.amazonaws.com/deploy.youappi.com/releases/latests/ROOT.war'
  action :create_if_missing
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
