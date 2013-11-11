#
# Cookbook Name:: youappi-base
# Recipe:: tag instance
#
# Copyright 2013, YouAPPI Ltd.
#
# All rights reserved - Do Not Redistribute
#



include_recipe "aws"

server_name = ENV['SERVER_NAME'] 
aws = data_bag_item("aws", "main")
mysql = data_bag_item("mysql","deploy")

#aws_resource_tag node['ec2']['instance_id']  do
#  aws_access_key aws['aws_access_key_id']
#  aws_secret_access_key aws['aws_secret_access_key']
#  tags({"Name" => "#{server_name}"})
#  action :add
#end


bash "register_broker_in_mysql" do
  user "root"
  code <<-EOH
     mysql -u#{mysql['user']} -p#{mysql['pass']} -hdb.youappi.com deploy -e "INSERT INTO registered_brokers (broker_dns,instance_id,inner_ip) VALUES('#{node['ec2']['public_hostname']}','#{node['ec2']['local_ipv4']}','#{node['ec2']['instance_id']}')"
  EOH
end



template "/etc/init.d/unregister_broker" do
  source "/unregister-broker.erb"
  owner "root"
  mode "0777"
  variables(
	:instance_id => node['ec2']['instance_id'],
	:mysql_user => mysql['user'],
	:mysql_pass => mysql['pass']
  )
end



link "/etc/rc0.d/S22unregister_broker" do 
  to "/etc/init.d/unregister_broker"
end

