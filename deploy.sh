#!/bin/bash

# Send a metric to statsd from bash
#
# Useful for:
#   deploy scripts (http://codeascraft.etsy.com/2010/12/08/track-every-release/)
#   init scripts
#   sending metrics via crontab one-liners
#   sprinkling in existing bash scripts.
#
# netcat options: 
#   -w timeout If a connection and stdin are idle for more than timeout seconds, then the connection is silently closed.  
#   -u         Use UDP instead of the default option of TCP.     
#
echo "deploys.$1:1|c" | nc -w 1 -u graphite.youappi.com 8125
