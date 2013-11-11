#
# Cookbook Name:: youappi-base
# Recipe:: default
#
# Copyright 2013, YouAPPI Ltd.
#
# All rights reserved - Do Not Redistribute
#


ENV['YOUAPPI_HOME'] = '/youappi/central/asgard/'
version = 'mysql deploy -e "SELECT version FROM releases ORDER BY release_time DESC LIMIT 1" --column-names=false | awk \'{print $1}\''
time = Time.now.strftime("%m%d%H%M%S")
server = 'tomix-' + time + '-' + version 

ENV['ROLE'] = 'API'
ENV['SERVER_NAME'] = server

file = '/opt/collectd/etc/collectd.conf'
text = File.read(file)
text.gsub!(/SERVER_NAME/,"collectd-#{server}")
File.open(file,'w') { |f| f.write(text)}



