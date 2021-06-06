#!/bin/bash
sudo amazon-linux-extras install nginx1
TOKEN=`curl -q -s -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600"` \
&& curl -q -s -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/placement/availability-zone > /usr/share/nginx/html/index.html
systemctl enable nginx
systemctl start nginx
