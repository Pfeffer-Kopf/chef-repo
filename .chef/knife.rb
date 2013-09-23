cwd                     = File.dirname(__FILE__)
log_level               :info   # valid values - :debug :info :warn :error :fatal
log_location            STDOUT
node_name               ENV.fetch('KNIFE_NODE_NAME', 'admin')
client_key              ENV.fetch('KNIFE_CLIENT_KEY', File.join(cwd,'admin.pem'))
chef_server_url         ENV.fetch('KNIFE_CHEF_SERVER_URL', 'https://chef.youappi.com')
validation_client_name  ENV.fetch('KNIFE_CHEF_VALIDATION_CLIENT_NAME', 'chef-validator')
validation_key          ENV.fetch('KNIFE_CHEF_VALIDATION_KEY', File.join(cwd,'chef-validator.pem'))
syntax_check_cache_path File.join(cwd,'syntax_check_cache')
cookbook_path           [File.join(cwd,'..','site-cookbooks'), File.join(cwd,'..','cookbooks')]
data_bag_path           File.join(cwd,'..','data_bags')
role_path               File.join(cwd,'..','roles')


# defaults
cookbook_copyright "YouAPPI Ltd."
# cookbook_email ""
# cookbook_license ""

knife[:aws_access_key_id] = ENV.fetch('AWS_ACCESS_KEY_ID', '')
knife[:aws_secret_access_key] = ENV.fetch('AWS_SECRET_ACCESS_KEY', '')
