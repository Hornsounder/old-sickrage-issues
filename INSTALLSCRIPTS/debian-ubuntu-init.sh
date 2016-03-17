#!/bin/bash --

if [[ $UID -ne 0 ]]; then
	echo 'Script must be run as root'
	exit 0
fi

if [[ $(cat /etc/issue) =~ Debian ]]; then
	distro=debian
elif [[ $(cat /etc/issue) =~ Ubuntu ]]; then
	distro=ubuntu
else
	echo "This script will only work on Debian and Ubuntu Distros, but you are using $(cat /etc/issue)"
	exit 0
fi

set -x

apt-get update
apt-get install unrar-free git-core openssl libssl-dev python2.7 -y

if [[ ! "$(getent group sickrage)" ]]; then
	addgroup --system sickrage
fi
if [[ ! "$(getent passwd sickrage)" ]]; then
	adduser --disabled-password --system --home /var/lib/sickrage --gecos "SickRage" --ingroup sickrage sickrage
fi

if [[ ! -d /opt/sickrage ]]; then
	mkdir /opt/sickrage && chown sickrage:sickrage /opt/sickrage
else
	rm -rf /opt/sickrage && mkdir /opt/sickrage && chown sickrage:sickrage /opt/sickrage
fi

su -c "git clone https://github.com/SickRage/SickRage.git /opt/sickrage" -s /bin/bash sickrage

if [[ $distro = ubuntu ]]; then
	if [[ $(/sbin/init --version) =~ upstart ]]; then

		cp -v /opt/sickrage/runscripts/init.upstart /etc/init/sickrage.conf
		
		chown root:root /etc/init/sickrage.conf
		chmod 644 /etc/init/sickrage.conf
		
		service sickrage start
		
	elif [[ $(systemctl) =~ -\.mount ]]; then
		
		cp -v /opt/sickrage/runscripts/init.systemd /etc/systemd/system/sickrage.service

		chown root:root /etc/systemd/system/sickrage.service
		chmod 644 /etc/systemd/system/sickrage.service

		systemctl enable sickrage
		systemctl start sickrage
		systemctl status sickrage
	else
		cp -v /opt/sickrage/runscripts/init.ubuntu /etc/init.d/sickrage
		
		chown root:root /etc/init.d/sickrage
		chmod 644 /etc/init.d/sickrage
		
		update-rc.d sickrage defaults
		service sickrage start
	fi
elif [[ $distro = debian ]]; then
	if [[ $(systemctl) =~ -\.mount ]]; then
		
		cp -v /opt/sickrage/runscripts/init.systemd /etc/systemd/system/sickrage.service

		chown root:root /etc/systemd/system/sickrage.service
		chmod 644 /etc/systemd/system/sickrage.service

		systemctl enable sickrage
		systemctl start sickrage
		systemctl status sickrage
	else
		cp -v /opt/sickrage/runscripts/init.debian /etc/init.d/sickrage
		
		chown root:root /etc/init.d/sickrage
		chmod 644 /etc/init.d/sickrage
		
		update-rc.d sickrage defaults
		service sickrage start
	fi
fi
set +x

while [[ ! $extip ]]; do
	extip=$(curl -s http://checkip.amazonaws.com/)
done

whiptail --title Complete --msgbox \ "Check that everything has been set up correctly by going to:
     
          Internal IP: http://$(ifconfig | grep 'inet addr' | cut -d ':' -f 2 | awk '{ print $1 }' | \
      grep -E '^(192\.168|10\.|172\.1[6789]\.|172\.2[0-9]\.|172\.3[01]\.)'):8081
                             OR
          External IP: http://$extip:8081

 make sure to add sickrage to your download clients group" 15 64
