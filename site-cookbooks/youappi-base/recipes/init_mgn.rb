#
# Cookbook Name:: youappi-base
# Recipe:: default
#
# Copyright 2013, YouAPPI Ltd.
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'aws'

ENV['ROLE'] = 'MGN'
ENV['ENV'] = 'prod'

aws = data_bag_item('aws', 'main')
ip_info = data_bag_item('aws', 'mgn_ip')

aws_elastic_ip 'elastic_ip_mgn' do
	 aws_access_key aws['aws_access_key_id']
	 aws_secret_access_key aws['aws_secret_access_key']
	 ip ip_info['ip']
	 action :associate
end
