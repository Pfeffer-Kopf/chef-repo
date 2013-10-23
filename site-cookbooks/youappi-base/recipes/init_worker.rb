#
# Cookbook Name:: youappi-base
# Recipe:: default
#
# Copyright 2013, YouAPPI Ltd.
#
# All rights reserved - Do Not Redistribute
#



bash "set_variables" do
  user "root"
  cwd "/etc"
  code <<-EOT
	echo "export YOUAPPI_HOME=/youappi/central >> /etc/enviroment"
	if [ "$ROLE" = "API" ]
	then
		echo "export SERVER_NAME=tomix-$(date +"%d%m%H%M%S") >> /etc/enviroment"
	else
		echo "export SERVER_NAME=mgn-$(date +"%d%m%H%M%S") >> /etc/enviroment"
	fi
	
	sed -i -e 's/SERVER_NAME/$SERVER_NAME/g' /opt/collectd/etc/collectd.conf
  EOT
end



service "collectd" do
  action [ :enable, :start ]
end

service "tomcat7" do
  action [ :enable, :start ]
end

