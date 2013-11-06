#
# Cookbook Name:: youappi-base
# Recipe:: default
#
# Copyright 2013, YouAPPI Ltd.
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'aws'

ENV['YOUAPPI_HOME'] = '/youappi/central/asgard/'


time = Time.now.strftime("%m%d%H%M%S")
server = 'mgn-' + time

ENV['SERVER_NAME'] = server
ENV['ROLE'] = 'MGN' 

file = '/opt/collectd/etc/collectd.conf'
text = File.read(file)
text.gsub!(/SERVER_NAME/,"collectd-#{server}")
File.open(file,'w') { |f| f.write(text)}



aws = data_bag_item("aws", "main")
ip_info = data_bag_item("aws", "mgn_ip")

aws_elastic_ip "elastic_ip_mgn" do
  aws_access_key aws['aws_access_key_id']
  aws_secret_access_key aws['aws_secret_access_key']
  ip ip_info['ip']
  action :associate
end


service "collectd" do
  action [ :enable, :restart ]
end

service "tomcat7" do
  action [ :enable, :restart ]
end


