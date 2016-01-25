#!/bin/bash
printf "\nWordPress Commantdline:\n"

DIRECTORY='/usr/local/bin/wp'

if [ -f "$DIRECTORY" ]; then
	printf "WPCLI is installed\n"
else
	printf "Install WPCLI\n"
	printf "Downliading WPCLI\n"
	curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
	php wp-cli.phar --info
	chmod +x wp-cli.phar
	printf "Move WPCLI to $DIRECTORY\n"
	sudo mv wp-cli.phar $DIRECTORY
	printf "\nWPCLI install finised\n"
fi
