#!/bin/sh

#teamspeak install script

cd "$(dirname "$0")" || exit 1

# check whether the dependencies curl, jq, and tar are installed
if ! command -v curl > /dev/null 2>&1; then
	echo 'curl not found' 1>&2
	exit 1
elif ! command -v jq > /dev/null 2>&1; then
        echo 'jq not found' 1>&2
        exit 1
elif ! command -v tar > /dev/null 2>&1; then
        echo 'tar not found' 1>&2
        exit 1
fi

# determine os and cpu architecture
os=$(uname -s)
if [ "$os" = 'Darwin' ]; then
	jqfilter='.macos'
else
	if [ "$os" = 'Linux' ]; then
		jqfilter='.linux'
	elif [ "$os" = 'FreeBSD' ]; then
		jqfilter='.freebsd'
	else
		echo 'Could not detect operating system. If you run Linux, FreeBSD, or macOS and get this error, please open an issue on Github.' 1>&2
		exit 1
	fi

	architecture=$(uname -m)
	if [ "$architecture" = 'x86_64' ] || [ "$architecture" = 'amd64' ]; then
		jqfilter="${jqfilter}.x86_64"
	else
		jqfilter="${jqfilter}.x86"
	fi
fi


server=$(curl -Ls 'https://www.teamspeak.com/versions/server.json' | jq "$jqfilter")

if [ -e 'CHANGELOG' ]; then
	old_version=$(grep -Eom1 'Server Release \S*' "CHANGELOG" | cut -b 16-)
else
	old_version='-1'
fi

version=$(printf '%s' "$server" | jq -r '.version')

if [ "$old_version" != "$version" ]; then
	echo "New version available: $version"
	checksum=$(printf '%s' "$server" | jq -r '.checksum')
	links=$(printf '%s' "$server" | jq -r '.mirrors | values[]')

	# order mirrors randomly
	if command -v shuf > /dev/null 2>&1; then
		links=$(printf '%s' "$links" | shuf)
	fi

	tmpfile=$(mktemp "${TMPDIR:-/tmp}/ts3updater.XXXXXXXXXX")
	i=1
	n=$(printf '%s\n' "$links" | wc -l)

	# try to download from mirrors until download is successful or all mirrors tried
	while [ "$i" -le "$n" ]; do
		link=$(printf '%s' "$links" | sed -n "$i"p)
		echo "Downloading the file $link"
		curl -Lo "$tmpfile" "$link"
		if [ $? = 0 ]; then
			i=$(( n + 1 ))
		else
			i=$(( i + 1 ))
		fi
	done

	if command -v sha256sum > /dev/null 2>&1; then
		sha256=$(sha256sum "$tmpfile" | cut -b 1-64)
	elif command -v shasum > /dev/null 2>&1; then
		sha256=$(shasum -a 256 "$tmpfile" | cut -b 1-64)
	elif command -v sha256 > /dev/null 2>&1; then
		sha256=$(sha256 -q "$tmpfile")
	else
		echo 'Could not generate SHA256 hash. Please make sure at least one of these commands is available: sha256sum, shasum, sha256' 1>&2
		rm "$tmpfile"
		exit 1
	fi

	if [ "$checksum" = "$sha256" ]; then
		tsdir=$(tar -tf "$tmpfile" | grep -m1 /)
		if [ ! -e '.ts3server_license_accepted' ]; then
			tar --to-stdout -xf "$tmpfile" "$tsdir"LICENSE
			echo -n "Accept license agreement (y/N)? "
			read answer
			if ! echo "$answer" | grep -iq "^y" ; then
				rm "$tmpfile"
				exit 1
			fi
		fi
		if [ -e 'ts3server_startscript.sh' ]; then
        		./ts3server_startscript.sh stop
		else
			sudo mkdir "$tsdir" || { echo 'Could not create installation directory. If you wanted to upgrade an existing installation, make sure to place this script INSIDE the existing installation directory.' 1>&2; rm "$tmpfile"; exit 1; }
			cd "$tsdir" && mv ../"$(basename "$0")" .
		fi

		tar --strip-components 1 -xf "$tmpfile" "$tsdir"
		touch .ts3server_license_accepted
		if [ "$1" != '--dont-start' ]; then
			./ts3server_startscript.sh start "$@"
		fi
	else
		echo 'Checksum of downloaded file is incorrect!' 1>&2
		rm "$tmpfile"
		exit 1
	fi

	rm "$tmpfile"
else
	echo "The installed server is up-to-date. Version: $version"
fi

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













