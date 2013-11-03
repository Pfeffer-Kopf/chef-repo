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
mysql = data_bag_item("mysql","deploy")

aws_resource_tag node['ec2']['instance_id']  do
  aws_access_key aws['aws_access_key_id']
  aws_secret_access_key aws['aws_secret_access_key']
  tags({"Name" => "#{server_name}"})
  action :add
end



bash "register_server_in_mysql" do
  user "root"
  code <<-EOH
     mysql -u#{mysql['user']} -p#{mysql['pass']} -hdb.youappi.com deploy -e "INSERT INTO registered_instances (instance_name,instance_id) VALUES('#{server_name}','#{node['ec2']['instance_id']}')"
  EOH
end



template "/etc/init.d/unregister" do
  source "/unregister.erb"
  owner "root"
  mode "0777"
  variables(
	:server_name => server_name,
	:mysql_user => mysql['user'],
	:mysql_pass => mysql['pass']
  )
end



link "/etc/rc0.d/S22unregister" do 
  to "/etc/init.d/unregister"
end

