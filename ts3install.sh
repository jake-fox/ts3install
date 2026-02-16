#!/usr/bin/env bash

apt update -y && apt upgrade -y
cd
wget https://files.teamspeak-services.com/releases/server/3.13.7/teamspeak3-server_linux_amd64-3.13.7.tar.bz2

sudo apt -y install lbzip2

tar -xf teamspeak3-server_linux_amd64-3.13.7.tar.bz2

rm teamspeak3-server_linux_amd64-3.13.7.tar.bz2

cd teamspeak3-server_linux_amd64

touch /root/teamspeak3-server_linux_amd64/.ts3server_license_accepted

sudo tee /lib/systemd/system/ts3server.service > /dev/null << 'EOF'
[Unit]
Description=Teamspeak Service
Wants=network.target

[Service]
WorkingDirectory=/root/teamspeak3-server_linux_amd64
User=root
ExecStart=/root/teamspeak3-server_linux_amd64/ts3server_minimal_runscript.sh
ExecStop=/root/teamspeak3-server_linux_amd64/ts3server_startscript.sh stop
ExecReload=/root/teamspeak3-server_linux_amd64/ts3server_startscript.sh restart
Restart=always
RestartSec=15

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl start ts3server
sudo systemctl enable ts3server


sudo journalctl -u ts3server --no-pager | grep -Ei 'password|token' | sed -E '
s/.*password.*: */ServerAdmin Password: /I;
s/.*token.*= */ServerAdmin Token: /I;
'











