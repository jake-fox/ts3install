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
echo type a voiceport for the server
read voiceport

touch /home/teamspeak3-server_linux_amd64/.ts3server.ini

echo
"machine_id=
default_voice_port=$voiceport
voice_ip=0.0.0.0
licensepath=/etc/teamspeak3-server/
filetransfer_port=30033
filetransfer_ip=0.0.0.0
query_port=10011
query_ip=0.0.0.0
query_ip_whitelist=/var/lib/teamspeak3-server/query_ip_whitelist.txt
query_ip_blacklist=/var/lib/teamspeak3-server/query_ip_blacklist.txt
dbplugin=ts3db_sqlite3
dbpluginparameter=
dbsqlpath=/usr/share/teamspeak3-server/sql/
dbsqlcreatepath=create_sqlite/
dblogkeepdays=90
logpath=/var/log/teamspeak3-server
logquerycommands=0
dbclientkeepdays=30" > /home/teamspeak3-server_linux_amd64/.ts3server.ini

./ts3server_startscript.sh start serveradmin_password=$pass


