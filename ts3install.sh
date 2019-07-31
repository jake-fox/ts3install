#!/bin/bash


#teamspeak install script
cd /home
sudo wget https://files.teamspeak-services.com/releases/server/3.9.1/teamspeak3-server_linux_amd64-3.9.1.tar.bz2
tar -xvf teamspeak3-server_linux_amd64-3.9.1.tar.bz2
rm -f teamspeak3-server_linux_amd64-3.9.1.tar.bz2
cd /home/teamspeak3-server_linux_amd64
chmod +x ./ts3server_startscript.sh
touch .ts3server_license_accepted


echo type a password for query serveradmin 
read pass

./ts3server_startscript.sh start serveradmin_password=$pass


