#
# Cookbook Name:: java7
# Recipe:: default
#

apt_repository "webupd8team" do
  uri "http://ppa.launchpad.net/webupd8team/java/ubuntu"
  components ['main']
  distribution node['lsb']['codename']
  keyserver "keyserver.ubuntu.com"
  key "EEA14886"
  deb_src true

end

# could be improved to run only on update
execute "accept-license" do
  command "echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections"
end

package "oracle-java7-installer" do
  action :install
end

package "oracle-java7-set-default" do
  action :install
end

ENV['JAVA_HOME']='/usr/lib/jvm/java-7-oracle/jre'

