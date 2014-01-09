#
# Cookbook Name:: youappi-base
# Recipe:: tag instance
#
# Copyright 2013, YouAPPI Ltd.
#
# All rights reserved - Do Not Redistribute
#


env = node['env']
role = node['role']

aws = data_bag_item('aws', 'main')

if env == 'prod' && role == 'API'

 template '/etc/init.d/package_logs' do
   source '/package_logs.erb'
   owner 'root'
   mode '0777'
   variables(
     :server => ENV['SERVER_NAME']
   )
 end
 
 link '/etc/rc0.d/S23pack_logs' do
   to '/etc/init.d/package_logs'
 end

 directory "/root/.aws" do
   owner 'root'
   group 'root'
   mode 00644
   action :create
 end

 template '/root/.aws/config' do
   source '/config_aws.erb'
   owner  'root'
   mode   '0777'
   variables( 
    	:aws_access_key_id => aws['aws_access_key_id'],
        :aws_secret_access_key => aws['aws_secret_access_key']
   )
 end

end


