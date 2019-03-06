#!/bin/bash


#teamspeak install script
cd /home
sudo wget https://files.teamspeak-services.com/releases/server/3.6.1/teamspeak3-server_linux_amd64-3.6.1.tar.bz2
tar -xvf teamspeak3-server_linux_amd64-3.6.1.tar.bz2
rm -f teamspeak3-server_linux_amd64-3.6.1.tar.bz2
cd /home/teamspeak3-server_linux_amd64
chmod +x ./ts3server_startscript.sh
touch .ts3server_license_accepted


echo type a password for query serveradmin 

read pass


echo type a queryport for server query

read query

./ts3server_startscript.sh start query_ip=127.0.0.1 query_port=$query serveradmin_password=$pass


