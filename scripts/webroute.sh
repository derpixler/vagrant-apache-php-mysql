#!/bin/bash

echo "set web root folder"

sudo rm -rf /var/www/html-vagrant
sudo ln -s /srv/html/ /var/www/html-vagrant


