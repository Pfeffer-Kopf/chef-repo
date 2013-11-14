include_recipe "logrotate"


logrotate_app 'nginx' do
  cookbook  'logrotate'
  path      '/var/log/nginx/*.log'
  create    '0640 www-data adm'
  size 	    '500M'
  rotate    25
  frequency 'daily'
  options   ['missingok', 'delaycompress', 'notifempty']
end
