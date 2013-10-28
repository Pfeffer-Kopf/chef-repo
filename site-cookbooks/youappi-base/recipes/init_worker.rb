#
# Cookbook Name:: youappi-base
# Recipe:: default
#
# Copyright 2013, YouAPPI Ltd.
#
# All rights reserved - Do Not Redistribute
#


ENV['YOUAPPI_HOME'] = '/youappi/asg/'

time = Time.now.strftime("%m%d%H%M%S")
server = ''
file = '/opt/collectd/etc/collectd.conf'
if ENV['ROLE'] == 'API'
	server = 'tomix-' + time
	ENV['SERVER_NAME'] = sever
elsif ENV['ROLE'] == 'MGN'
	server = 'mgn-' + time
	ENV['SERVER_NAME'] = server
end


text = File.read(file)
text.gsub!(/SERVER_NAME/,server)
File.open(file,'w') { |f| f.write(text)}




service "collectd" do
  action [ :enable, :restart ]
end

service "tomcat7" do
  action [ :enable, :restart ]
end


