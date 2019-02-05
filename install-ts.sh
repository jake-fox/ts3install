#!/bin/bash
clear
cd ~/home
useradd --disabled-login teamspeak
wget https://files.teamspeak-services.com/releases/server/3.6.0/teamspeak3-server_linux_amd64-3.6.0.tar.bz2
tar xvf 3.6.0.tar.bz2
cd teamspeak3-server_linux_amd64
mv * /home/teamspeak
cd ..
rm -rf teamspeak3*
touch /home/teamspeak/.ts3server_license_accepted
sudo chown -R teamspeak:teamspeak /home/teamspeak
iptables -A INPUT -p udp --dport 9987 -j ACCEPT
iptables -A INPUT -p udp --sport 9987 -j ACCEPT
iptables -A INPUT -p tcp --dport 30033 -j ACCEPT
iptables -A INPUT -p tcp --sport 30033 -j ACCEPT
iptables -A INPUT -p tcp --dport 10011 -j ACCEPT
iptables -A INPUT -p tcp --sport 10011 -j ACCEPT
wget -O /home/teamspeak/start-ts.sh https://lochstudioscdn.nyc3.cdn.digitaloceanspaces.com/scripts/static/teamspeak/start-ts.sh
cd /home/teamspeak
./start-ts.sh