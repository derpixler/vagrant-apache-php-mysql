#!/usr/bin/env bash

# install php7 inkl. xdebug
sudo apt-get update -y
sudo add-apt-repository ppa:ondrej/php  -y
sudo apt-get update  -y
sudo apt-get install php7.0 php7.0-mysql libapache2-mod-php7.0 php7.0-xdebug php7.0-dev  -y
sudo a2dismod php5
sudo a2enmod php7.0
sudo apachectl restart

# enable display errors
sudo vi /etc/php/7.0/apache2/php.ini
sudo service apache2  restart
