name             'youappi-base'
maintainer       'YouAPPI Ltd.'
maintainer_email 'YOUR_EMAIL'
license          'All rights reserved'
description      'Installs/Configures youappi-base'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.0.9'


depends "tomcat", "~> 0.14.4"
depends "users", "~> 1.6.1"
depends "sudo", "~> 2.2.3"
depends "mercurial", "~> 2.0.3"
depends "aws","~> 1.0.1"
depends "logrotate","~> 1.4.1"
