#
# Cookbook Name:: youappi-base
# Recipe:: default
#
# Copyright 2013, YouAPPI Ltd.
#
# All rights reserved - Do Not Redistribute
#


ENV['YOUAPPI_HOME'] = '/youappi/central/asgard/'


time = Time.now.strftime("%m%d%H%M%S")
server = 'tomix-' + time

ENV['ROLE'] = 'API'
ENV['SERVER_NAME'] = server

file = '/opt/collectd/etc/collectd.conf'
text = File.read(file)
text.gsub!(/SERVER_NAME/,"collectd-#{server}")
File.open(file,'w') { |f| f.write(text)}




service "collectd" do
  action [ :enable, :restart ]
end

service "tomcat7" do
  action [ :enable, :restart ]
end


