#!/bin/bash
INDEX="/var/www/html/index.html"
yum install -y httpd
hostname >> $INDEX
chmod 444
systemctl enable httpd
systemctl start httpd