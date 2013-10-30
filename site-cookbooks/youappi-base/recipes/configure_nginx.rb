include_recipe "mercurial"


template "/etc/nginx/sites-available/default" do
        source "default.erb"
end

template "/etc/nginx/sites-available/youappi-default-tomcat" do
        source "youappi-default-tomcat.erb"
end

template "/etc/nginx/sites-available/nginx-status" do
        source "nginx-status.erb"
end


link "/etc/nginx/sites-enabled/default" do
  to "/etc/nginx/sites-available/default"
end

link "/etc/nginx/sites-enabled/youappi-default-tomcat" do
  to "/etc/nginx/sites-available/youappi-default-tomcat"
end


link "/etc/nginx/sites-enabled/nginx-status" do
  to "/etc/nginx/sites-available/nginx-status"
end

bitbucket = data_bag_item("users","bitbucket")

directory "/var/www/" do
  owner "root"
  group "root"
  recursive true
  mode 00644
  action :create
end

bash "checkout_php" do
  cwd "/var/www/"
  user "root"
  code <<-EOH
   hg clone https://#{bitbucket['user']}:#{bitbucket['pass']}@bitbucket.org/ofergarnett/youappi-php --rev stable widget-server
  EOH
end

