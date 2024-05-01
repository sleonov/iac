#!/bin/bash

sudo yum update -y
sudo yum install -y httpd.x86_64
echo Howdy from "$(hostname)" | sudo tee -a /var/www/html/index.html
sudo systemctl start httpd.service
sudo systemctl enable httpd.service