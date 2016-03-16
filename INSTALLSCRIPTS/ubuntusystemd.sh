#!/bin/bash --

if [[ $UID -ne 0 ]]; then
	echo 'Script must be run as root'
	exit 0
fi

set -x

apt-get update
apt-get install unrar-free git-core openssl libssl-dev python2.7 -y

addgroup --system sickrage
adduser --disabled-password --system --home /var/lib/sickrage --gecos "SickRage" --ingroup sickrage sickrage

mkdir /opt/sickrage && chown sickrage:sickrage /opt/sickrage
su -u sickrage git clone https://github.com/SickRage/SickRage.git /opt/sickrage

cp -v /opt/sickrage/runscripts/init.systemd /etc/systemd/system/sickrage.service

chown root:root /etc/systemd/system/sickrage.service
chmod 644 /etc/systemd/system/sickrage.service

systemctl enable sickrage
systemctl start sickrage
systemctl status sickrage

set +x

echo "Check that everything has been set up correctly by going to http://yourserverip.com/8081"