#
# Cookbook Name:: youappi-base
# Recipe:: tag instance
#
# Copyright 2013, YouAPPI Ltd.
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'aws'

env = node['env']
role = node['role']

ENV['YOUAPPI_HOME'] = '/youappi/central/' + env
ENV['ENV'] = env
ENV['ROLE'] = role

aws = data_bag_item('aws', 'main')
mysql = data_bag_item('mysql', 'deploy')


version = `mysql -u#{mysql['user']} -p#{mysql['pass']} -h#{mysql['host']} deploy -e "SELECT release_id FROM worker_ami WHERE ami_id='#{node['ec2']['ami_id']}'" --column-names=false | awk '{print $1}'`
branch = `mysql -u#{mysql['user']} -p#{mysql['pass']} -h#{mysql['host']} deploy -e "SELECT branch FROM worker_ami WHERE ami_id='#{node['ec2']['ami_id']}'" --column-names=false | awk '{print $1}'`

time = Time.now.strftime('%m%d%H%M%S')

server = "#{role == 'API' ? 'tomix' : 'mgn'}-#{time}-#{version.tr("\n", '')}"
if env != 'prod'
  server += ('-' + env)
end

ENV['SERVER_NAME'] = server

file = '/opt/collectd/etc/collectd.conf'
text = File.read(file)
text.gsub!(/SERVER_NAME/, "collectd-#{server}")
File.open(file, 'w') { |f| f.write(text) }

aws_resource_tag node['ec2']['instance_id'] do
  aws_access_key aws['aws_access_key_id']
  aws_secret_access_key aws['aws_secret_access_key']
  tags({'Name' => server,
	'Env'  => env,
	'Branch' => branch})
  action :add
end


bash 'set_enviroment' do
  user 'root'
  code <<-EOH
     echo "export ROLE=#{role}\nexport SERVER_NAME=#{server}\nexport ROLE=#{role}\nexport YOUAPPI_HOME=#{ENV['YOUAPPI_HOME']}\nexport ENV=#{env}\n" >> /etc/environment
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


if env == 'prod' && role == 'MGN'
  ip_info = data_bag_item('aws', 'mgn_ip')
  aws_elastic_ip 'elastic_ip_mgn' do
    aws_access_key aws['aws_access_key_id']
    aws_secret_access_key aws['aws_secret_access_key']
    ip ip_info['ip']
    action :associate
  end

  service 'rabbitmq-stop' do 
    action :stop
  end

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
