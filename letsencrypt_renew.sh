#!/bin/bash

install_dir="/opt/letsencrypt"
email="root@asauna.io"
reload_services="postfix nginx"
restart_services="dovecot"

test="./letsencrypt-auto renew --agree-tos --email $email"

if [ "$(id -u)" != "0" ]; then
	echo "This script must be run as root"
	exit 1
fi

if [ -d "$install_dir" ]
then
	cd $install_dir
	$test | grep "No renewals"

	if [ $? -eq 1 ];
	then
		# Reload services
		for srv in $reload_services; do
			systemctl reload $srv
			echo "Reloaded unit: $srv"
		done

		# Restart services
		for srv in $restart_services; do
			systemctl restart $srv
			echo "Restarted unit: $srv"
		done
	else
		echo "No renewals were made."
	fi
else
	echo "Install_dir not found :("
fi
