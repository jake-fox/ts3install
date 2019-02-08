#!/bin/sh

#teamspeak install script
cd /home
wget https://files.teamspeak-services.com/releases/server/3.6.1/teamspeak3-server_linux_amd64-3.6.1.tar.bz2
tar -xvf teamspeak3-server_linux_amd64-3.6.1.tar.bz2
cd /teamspeak3-server_linux_amd64
chmod +x ./ts3server_startscript.sh
./ts3server_startscript.sh start
./ts3server_startscript.sh status
exit 0
done


#webinterface script

cd /home
apt update
apt upgrade -y
apt install ca-certificates apt-transport-https lsb-release curl nano unzip -y
wget -q https://packages.sury.org/php/apt.gpg -O- | apt-key add -
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list
apt update
apt install apache2 -y
apt install php7.3 php7.3-cli php7.3-curl php7.3-gd php7.3-intl php7.3-json php7.3-mbstring php7.3-mysql php7.3-opcache php7.3-readline php7.3-xml php7.3-xsl php7.3-zip php7.3-bz2 libapache2-mod-php7.3 -y
apt install mariadb-server mariadb-client -y
mysql_secure_installation
systemctl restart apache2
cd /usr/share
wget https://files.phpmyadmin.net/phpMyAdmin/4.8.5/phpMyAdmin-4.8.5-all-languages.zip
unzip phpMyAdmin-4.8.5-all-languages.zip
rm phpMyAdmin-4.8.5-all-languages.zip
mv phpMyAdmin-4.8.5-all-languages phpmyadmin
chmod -R 0755 phpmyadmin
nano /etc/apache2/conf-available/phpmyadmin.conf

# phpMyAdmin Apache configuration

echo "Alias /phpmyadmin /usr/share/phpmyadmin

<Directory /usr/share/phpmyadmin>
    Options SymLinksIfOwnerMatch
    DirectoryIndex index.php
</Directory>

# Disallow web access to directories that don't need it
<Directory /usr/share/phpmyadmin/templates>
    Require all denied
</Directory>
<Directory /usr/share/phpmyadmin/libraries>
    Require all denied
</Directory>
<Directory /usr/share/phpmyadmin/setup/lib>
    Require all denied
</Directory>" /etc/apache2/conf-available/phpmyadmin.conf

+o
+x

a2enconf phpmyadmin
systemctl reload apache2

mysql -u root
UPDATE mysql.user SET plugin = 'mysql_native_password' WHERE user = 'root' AND plugin = 'unix_socket';
FLUSH PRIVILEGES;
exit

cd /var/www/html
wget https://www.bennetrichter.de/downloads/ts3wi.zip
ls
unzip ts3wi.zip
rm ts3wi.zip
cd ts3wi
#nano config.php #$server[0]['ip']
chmod -R 777 icons/ temp/ templates_c/ site/backups/













