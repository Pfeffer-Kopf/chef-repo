#
# Cookbook Name:: youappi-base
# Recipe:: tag instance
#
# Copyright 2013, YouAPPI Ltd.
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'aws'

env = ENV['ENV']

ENV['YOUAPPI_HOME'] = '/youappi/central/' + env

aws = data_bag_item('aws', 'main')
mysql = data_bag_item('mysql', 'deploy')


version = `mysql -u#{mysql['user']} -p#{mysql['pass']} -hdb.youappi.com deploy -e "SELECT version FROM releases ORDER BY release_time DESC LIMIT 1" --column-names=false | awk '{print $1}'`
time = Time.now.strftime('%m%d%H%M%S')

server = "#{(ENV['ROLE'] == 'API' ? 'tomix' : 'mgn')}-#{time}-#{version.tr("\n", '')}#{env=='stg' ? '-stg' : ''}"

ENV['SERVER_NAME'] = server

file = '/opt/collectd/etc/collectd.conf'
text = File.read(file)
text.gsub!(/SERVER_NAME/, "collectd-#{server}")
File.open(file, 'w') { |f| f.write(text) }

aws_resource_tag node['ec2']['instance_id'] do
  aws_access_key aws['aws_access_key_id']
  aws_secret_access_key aws['aws_secret_access_key']
  tags({'Name' => "#{server}"})
  action :add
end


bash 'set_enviroment' do
  user 'root'
  code <<-EOH
     echo "export SERVER_NAME=#{server}\nexport ROLE=#{ENV['ROLE']}\nexport YOUAPPI_HOME=#{ENV['YOUAPPI_HOME']}\nexport ENV=#{env}\n" >> /etc/environment
  EOH
end


bash 'register_server_in_mysql' do
  user 'root'
  code <<-EOH
	     mysql -u#{mysql['user']} -p#{mysql['pass']} -h#{mysql['host']} deploy -e "INSERT INTO registered_instances (instance_name,instance_id,environment) VALUES('#{server}','#{node['ec2']['instance_id']}','#{env}')"
  EOH
end

template '/etc/init.d/unregister' do
  source '/unregister.erb'
  owner 'root'
  mode '0777'
  variables(
      :server_name => server,
      :mysql_user => mysql['user'],
      :mysql_pass => mysql['pass'],
      :mysql_host => mysql['host']
  )
end

link '/etc/rc0.d/S22unregister' do
  to '/etc/init.d/unregister'
end

service 'collectd' do
  action [:enable, :restart]
end

service 'tomcat7' do
  action [:enable, :restart]
end
