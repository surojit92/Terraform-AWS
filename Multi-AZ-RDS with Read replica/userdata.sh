#! /bin/bash
sudo su
sudo yum update -y
sudo yum install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd
echo  "Welcome to AWS" > /var/www/html/index.html
