#!/bin/bash
sudo yum install httpd -y
sudo echo "Welcome to my EC2 Server" > /usr/share/nginx/html/index.html
sudo yum update -y
sudo service httpd start