#!/bin/bash

#Verify that the script is running as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# set -x #echo on

#Update the system and install epel repo
yum -y update
yum -y install epel-release gcc kernel-devel


##############
#Install Plex#
##############

#Enable Plex repo
echo '[PlexRepo]
name=PlexRepo
baseurl=https://downloads.plex.tv/repo/rpm/$basearch/
enabled=1
gpgkey=https://downloads.plex.tv/plex-keys/PlexSign.key
gpgcheck=1' > /etc/yum.repos.d/plex.repo

#Install Plex applicaiton
yum -y install plexmediaserver



#############################
#Plex Firewall Configuration#
#############################

#Create a firewalld service file for Plex
#generates an XML file with the firewall rules for Plex
echo '<?xml version="1.0" encoding="utf-8"?>
<service version="1.0">
  <short>plexmediaserver</short>
  <description>Plex TV Media Server</description>
  <port port="1900" protocol="udp"/>
  <port port="5353" protocol="udp"/>
  <port port="32400" protocol="tcp"/>
  <port port="32410" protocol="udp"/>
  <port port="32412" protocol="udp"/>
  <port port="32413" protocol="udp"/>
  <port port="32414" protocol="udp"/>
  <port port="32469" protocol="tcp"/>
</service>' > /etc/firewalld/services/plexmediaserver.xml

#restart the firewall to recognize new service
systemctl restart firewalld.service

#add the service rules and then register them in the public zone
firewall-cmd --permanent --add-service=plexmediaserver

#restart to reload rules
systemctl restart firewalld.service



#####################
#Enable and run Plex#
#####################

systemctl enable plexmediaserver.service
systemctl start plexmediaserver.service
systemctl status plexmediaserver.service

echo "Access Plex at http://127.0.0.1:32400/web/index.html"