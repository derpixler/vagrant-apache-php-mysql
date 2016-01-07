#!/bin/bash
echo "Create virtualHosts"

write_vHosts() {

	URL=$1
	subFolder=$2
	path=$3
	aliases=$4

	DocumentRoot="/var/www/html-vagrant/${path}"
	confFile=/etc/apache2/sites-available/${URL//'.'/'_'}.conf
	logFilePah="/srv/log/apache2/vhosts/"

	if [ $2 ]
	then
		DocumentRoot="/var/www/html-vagrant/${subFolder}/${path}"
	fi

	if [ ! -d "$DocumentRoot" ]; then
		echo "Erstelle verzeichniss" ${DocumentRoot}
		mkdir -p ${DocumentRoot}
		echo "ok!" >> "${DocumentRoot}/index.html"
	fi

	if [ ! -d "$logFilePah" ]; then
		echo "Erstelle log verzeichniss" ${logFilePah}
		mkdir -p ${logFilePah}
	fi


   	echo "Create the vHost for" $1


   # Create the base apache configuration for the site
   cat  > ${confFile} <<EOF
<VirtualHost *:80>

	ServerName localhost
	${aliases}

	CustomLog /srv/log/apache2/vhosts/${URL//'.'/'_'}.log vhost_combined

	DocumentRoot ${DocumentRoot}/

	<Directory ${DocumentRoot}>
		Options Indexes FollowSymLinks MultiViews
		AllowOverride all
		Order allow,deny
		allow from all
	</Directory>

</VirtualHost>
EOF


	echo "Enabling site ${URL}."
	if [ -f "${confFile//available/enabled}" ]; then
		sudo unlink ${confFile//available/enabled}
	fi
	sudo ln -s $confFile ${confFile//available/enabled}

	echo '---'
}


filename="/srv/config/hosts.list"
content=$(cat $filename)
mod=${content//' '/''}
IFS=' ' read -ra lines <<< "$mod"
for line in $mod
do
	if [ "${line:0:1}" != '#' ]
	then

		IFS='|' read -ra hosts <<< "$line"
		if [ ${#hosts[@]} > 1 ]
		then

			samehosts=''
			for (( i=0; i<${#hosts[@]}; i++ ));
			do
samehosts+="ServerAlias ${hosts[$i]}
	 "
			done

			IFS='.' read -ra host <<< "${hosts[0]}"

			if [ ${#host[@]} = 3 ]
			then
				write_vHosts ${hosts[0]} ${host[0]} ${host[1]} "${samehosts}"
			elif [ ${#host[@]} = 2 ]
			then
				write_vHosts ${hosts[0]} ${host[0]} ${host[1]} "${samehosts}"
				#elif [ ${#host[@]} = 1 ]
				#then
				#write_vHosts ${hosts[0]} "" ${host[0]} "${samehosts}"
			fi

			apacheReload=1
		fi
	fi
done

if [ $apacheReload ]
then
	sudo service apache2 restart
fi

echo Install done