#!/usr/bin/env bash

##
# installing and activating VHost config
# for this virtualmaschine if not already exists
#

echo "Create virtualHosts"

write_vHosts() {

	URL=$1
	aliases=$2
	path=${URL//'.'/'_'}

	DocumentRoot="/var/www/${path}"

	vhostFile=${URL//'.'/'_'}.conf
	vhostPath="/etc/apache2/sites-available/"
	confFile="${vhostPath}${vhostFile}"

	logFilePah="/srv/log/apache2/vhosts/"

	#if [ $2 ]
	#then
	#	DocumentRoot="/var/www/${path}"
	#fi

	if [ ! -d "$DocumentRoot" ]; then
		echo "Erstelle verzeichniss" ${DocumentRoot}
		mkdir -p ${DocumentRoot}
		echo "ok!" >> "${DocumentRoot}/index.html"
	fi

	if [ ! -d "$vhostPath" ]; then
		echo "Erstelle verzeichniss" ${vhostPath}
		mkdir -p ${vhostPath}
	fi

	if [ ! -d "$logFilePah" ]; then
		echo "Erstelle log verzeichniss" ${logFilePah}
		mkdir -p ${logFilePah}
	fi

	echo "Delete /var/www/${DocumentRoot}"
	sudo rm -rf ${DocumentRoot}

	echo "Create Symlink into WordPress folder"
	sudo ln -s /var/www/wordpress ${DocumentRoot}

	rm -rf ${confFile}

   	echo "Create the vHost for" $1

	conf=$(cat <<EOF
<VirtualHost *:80>

	ServerName localhost
	ServerAlias ${URL}
	${aliases}

	CustomLog /srv/log/apache2/vhosts/${URL//'.'/'_'}.log vhost_combined

		DocumentRoot ${DocumentRoot}/

		<Directory ${DocumentRoot} >
			Options Indexes FollowSymLinks MultiViews
			AllowOverride
			allow from all
		</Directory>

</VirtualHost>
EOF
)



echo -e $conf >> ${confFile}

   # Create the base apache configuration for the site
#   cat  > ${confFile} <<EOF
#<VirtualHost *:80>
#
#	ServerName localhost
#	ServerAlias ${URL}
#    ${aliases}
#
#	CustomLog /srv/log/apache2/vhosts/${URL//'.'/'_'}.log vhost_combined
#
#	DocumentRoot ${DocumentRoot}/
#
#	<Directory ${DocumentRoot}>
#		Options Indexes FollowSymLinks MultiViews
#		AllowOverride all
#		Order allow,deny
#		allow from all
#	</Directory>
#
#</VirtualHost>
#EOF
#

	echo "Enabling site ${URL}."
	if [ -f "${confFile//available/enabled}" ]; then
		sudo unlink ${confFile//available/enabled}
	fi
	sudo ln -s $confFile ${confFile//available/enabled}



	echo '---'
}

file_name="/vagrant/vagrant.json"

if [ ! -e "$file_name" ]
then
	file_name="/vagrant/vagrant.dist.json"
fi

host=$(node -pe 'JSON.parse(process.argv[1]).network.private_network.host' "$(cat $file_name)")
alias=$(node -pe 'JSON.parse(process.argv[1]).network.private_network.alias' "$(cat $file_name)")

alias="${alias//[$'\t\r\n ']}"

mod=${alias//"'"/''}
mod=${mod//'['/''}
alias=${mod//']'/''}



IFS=', '; array=($alias)
for item in ${array[@]}; do
	samehosts+="\tServerAlias $item\n"
done

write_vHosts $host "${samehosts}"

sudo service apache2 reload
