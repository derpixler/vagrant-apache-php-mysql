echo Installing LAMP stack
apt-get update -y
# set mysql user to root/root
debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password password root'
debconf-set-selections <<< 'mysql-server-5.5 mysql-server/root_password_again password root'
# install LAMP
sudo apt-get install -y apache2 libapache2-mod-php5 php5 php5-mysql mysql-server php5-xdebug
sudo service mysql stop
# allow mysql access from network
sudo sed -i "s/bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/my.cnf
sudo service mysql start
# set mysql privileges to allow root access from all hosts
echo "use mysql;update user set host='%' where user='root' and host='#{$hostname}';flush privileges;" | mysql -uroot -proot

echo "ServerName localhost" >> /etc/apache2/apache2.conf


# activate Xdebug remote debugging
sudo cat > /etc/php5/mods-available/xdebug.ini << EOF
zend_extension=xdebug.so
xdebug.remote_enable=On
xdebug.remote_connect_back=On
xdebug.remote_autostart=Off
xdebug.remote_log=/tmp/xdebug.log
EOF

echo "Enable Apache ModRewrite"
# activate mod rewrite
a2enmod rewrite

echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password root" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-pass password root" | debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password root" | debconf-set-selections
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect none" | debconf-set-selections
sudo apt-get -y install phpmyadmin > /dev/null 2>&1


# git
echo "Installing git"
sudo apt-get install -y git



# PHPUnit
#
# Check that PHPUnit, Mockery, and Hamcrest are all successfully installed.
# If not, then Composer should be given another shot at it. Versions for
# these packages are controlled in `/srv/config/phpunit-composer.json`.
#echo "Install PHPUnit"
#if [[ ! -d /usr/local/src/vvv-phpunit ]]; then
#	echo "Installing PHPUnit, Hamcrest and Mockery..."
#	mkdir -p /usr/local/src/vvv-phpunit
#	cp /srv/config/phpunit-composer.json /usr/local/src/vvv-phpunit/composer.json
#	sh -c "cd /usr/local/src/vvv-phpunit && composer install"
#else
#	cd /usr/local/src/vvv-phpunit
#	if [[ -n "$(composer show -i | grep -q 'mockery')" ]]; then
#		echo "Mockery installed"
#	else
#		vvvphpunit_update=1
#	fi
#	if [[ -n "$(composer show -i | grep -q 'phpunit')" ]]; then
#		echo "PHPUnit installed"
#	else
#		vvvphpunit_update=1
#	fi
#	if [[ -n "$(composer show -i | grep -q 'hamcrest')" ]]; then
#		echo "Hamcrest installed"
#	else
#		vvvphpunit_update=1
#	fi
#	cd ~/
#fi
#
#if [[ "$vvvphpunit_update" = 1 ]]; then
#	echo "Update PHPUnit, Hamcrest and Mockery..."
#	cp /srv/config/phpunit-composer.json /usr/local/src/vvv-phpunit/composer.json
#	sh -c "cd /usr/local/src/vvv-phpunit && composer update"
#fi

rm /home/vagrant/.bash_profile
rm /home/vagrant/.bash_aliases
rm /home/vagrant/.bashrc

echo "create bash symlink"
ln -s /srv/config/bash_profile /home/vagrant/.bash_profile
ln -s /srv/config/bash_aliases /home/vagrant/.bash_aliases
ln -s /srv/config/bash_aliases /home/vagrant/.bashrc


# If MySQL is installed, go through the various imports and service tasks.
exists_mysql="$(service mysql status)"
if [[ "mysql: unrecognized service" != "${exists_mysql}" ]]; then
	echo -e "\nSetup MySQL configuration file links..."

	# Copy mysql configuration from local
	cp /srv/config/mysql-config/my.cnf /etc/mysql/my.cnf
	cp /srv/config/mysql-config/root-my.cnf /home/vagrant/.my.cnf

	echo " * /srv/config/mysql-config/my.cnf               -> /etc/mysql/my.cnf"
	echo " * /srv/config/mysql-config/root-my.cnf          -> /home/vagrant/.my.cnf"

	# MySQL gives us an error if we restart a non running service, which
	# happens after a `vagrant halt`. Check to see if it's running before
	# deciding whether to start or restart.
	if [[ "mysql stop/waiting" == "${exists_mysql}" ]]; then
		echo "service mysql start"
		service mysql start
	else
		echo "service mysql restart"
		service mysql restart
	fi

	# IMPORT SQL
	#
	# Create the databases (unique to system) that will be imported with
	# the mysqldump files located in database/backups/
	if [[ -f /srv/database/init-custom.sql ]]; then
		mysql -u root -proot < /srv/database/init-custom.sql
		echo -e "\nInitial custom MySQL scripting..."
	else
		echo -e "\nNo custom MySQL scripting found in database/init-custom.sql, skipping..."
	fi

	# Setup MySQL by importing an init file that creates necessary
	# users and databases that our vagrant setup relies on.
	mysql -u root -proot < /srv/database/init.sql
	echo "Initial MySQL prep..."

	# Process each mysqldump SQL file in database/backups to import
	# an initial data set for MySQL.
	/srv/scripts/import-sql.sh
else
	echo -e "\nMySQL is not installed. No databases imported."
fi


echo Install done