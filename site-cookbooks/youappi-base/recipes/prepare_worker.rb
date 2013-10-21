#
# Cookbook Name:: youappi-base
# Recipe:: default
#
# Copyright 2013, YouAPPI Ltd.
#
# All rights reserved - Do Not Redistribute
#



service "tomcat7" do
  action :stop
end

remote_file "/usr/share/tomcat7/webapp/ROOT.war" do
  source "https://s3.amazonaws.com/deploy.youappi.com/releases/latests"
  action create_if_missing
end

service "tomcat7" do
  action :start
end