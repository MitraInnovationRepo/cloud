#!/bin/sh
apt-get update
apt-get install apache2 -y
echo "<h1>You are viewing the Public Subnet Dev Instance</h1>" > /var/www/html/index.html