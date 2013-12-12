include_recipe 'apt'

apt_package 'python-software-properties' do
  action :install
end

`add-apt-repository ppa:duh/golang -y`

`apt-get update`

apt_package 'golang' do
  action :install
end

remote_file '/opt/gor' do
  source 'https://github.com/buger/gor/releases/download/0.7.0/gor-amd64'
  mode 00111
end
