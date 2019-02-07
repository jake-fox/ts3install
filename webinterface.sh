#!/bin/sh

apt update
apt upgrade -y
apt install ca-certificates apt-transport-https lsb-release curl nano unzip -y 
wget -q https://packages.sury.org/php/apt.gpg -O- | apt-key add -
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list 
apt update
apt install apache2 -y 
apt install php7.3 php7.3-cli php7.3-curl php7.3-gd php7.3-intl php7.3-json php7.3-mbstring php7.3-mysql php7.3-opcache php7.3-readline php7.3-xml php7.3-xsl php7.3-zip php7.3-bz2 libapache2-mod-php7.3 -y 
apt install mariadb-server mariadb-client -y
mysql_secure_installation && systemctl restart apache2
apt update
apt upgrade -y
apt install nano unzip -y
cd /var/www/html
wget https://www.bennetrichter.de/downloads/ts3wi.zip
ls
unzip ts3wi.zip
rm ts3wi.zip
cd ts3wi
chmod -R 777 icons/ temp/ templates_c/ site/backups/
nano /home/ts3/teamspeak3-server_linux_amd64/query_ip_whitelist.txt
