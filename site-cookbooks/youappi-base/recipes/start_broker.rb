#
# Cookbook Name:: youappi-base
# Recipe:: tag instance
#
# Copyright 2013, YouAPPI Ltd.
#
# All rights reserved - Do Not Redistribute
#


include_recipe 'aws'

aws = data_bag_item('aws', 'main')
mysql = data_bag_item('mysql', 'deploy')
env = ENV['ENV']
bash 'register_broker_in_mysql' do
  user 'root'
  code <<-EOH
     mysql -u#{mysql['user']} -p#{mysql['pass']} -h#{mysql['host']} deploy -e "INSERT INTO registered_brokers (broker_dns, inner_ip, instance_id, enviroment)  VALUES('#{node['ec2']['public_hostname']}','#{node['ec2']['local_ipv4']}','#{node['ec2']['instance_id']}','#{env}')"
  EOH
end

id = `mysql -u#{mysql['user']} -p#{mysql['pass']} -h#{mysql['host']} deploy -e "SELECT id FROM registered_brokers WHERE instance_id ='#{node['ec2']['instance_id']}'" --column-names=false | awk '{print $1}'`


aws_resource_tag node['ec2']['instance_id'] do
  aws_access_key aws['aws_access_key_id']
  aws_secret_access_key aws['aws_secret_access_key']
  tags({'Name' => "BROKER-#{id}"})
  action :update
end

template '/etc/init.d/unregister_broker' do
  source '/unregister-broker.erb'
  owner 'root'
  mode '0777'
  variables(
      :server_name => server,
      :mysql_user => mysql['user'],
      :mysql_pass => mysql['pass'],
      :mysql_host => mysql['host']
  )

end


link '/etc/rc0.d/S22unregister_broker' do
  to '/etc/init.d/unregister_broker'
end

