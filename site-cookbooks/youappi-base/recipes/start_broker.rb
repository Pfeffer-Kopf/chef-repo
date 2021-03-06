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
rabbitmq = data_bag_item('rabbitmq', 'cookie')


env = node['env']

bash 'register_broker_in_mysql' do
  user 'root'
  code <<-EOH
     mysql -u#{mysql['user']} -p#{mysql['pass']} -h#{mysql['host']} deploy -e "INSERT INTO registered_brokers (broker_dns, inner_ip, instance_id, environment)  VALUES('#{node['ec2']['public_hostname']}','#{node['ec2']['local_ipv4']}','#{node['ec2']['instance_id']}','#{env}')"
  EOH
end

id = `mysql -u#{mysql['user']} -p#{mysql['pass']} -h#{mysql['host']} deploy -e "SELECT id FROM registered_brokers ORDER BY id DESC LIMIT 1" --column-names=false | awk '{print $1}'`

#aws_resource_tag node['ec2']['instance_id'] do
#  aws_access_key aws['aws_access_key_id']
#  aws_secret_access_key aws['aws_secret_access_key']
#  tags({'Name' => "broker-#{id.strip}-#{env}",
#	'Env'  => env })
#  action :update
#end

template '/etc/init.d/unregister_broker' do
  source '/unregister-broker.erb'
  owner 'root'
  mode '0777'
  variables(
      :mysql_user => mysql['user'],
      :mysql_pass => mysql['pass'],
      :mysql_host => mysql['host'],
      :instance_id => node['ec2']['instance_id']
  )

end


link '/etc/rc0.d/S22unregister_broker' do
  to '/etc/init.d/unregister_broker'
end

template '/var/lib/rabbitmq/.erlang.cookie' do
  source 'rabbit-cookie.erb'
  owner 'rabbitmq'
  mode '0400'
  variables(
	:cookie => rabbitmq[env]
  )
end

#`killall -9 beam`

#service "rabbitmq-server" do
#  action :restart
#end
