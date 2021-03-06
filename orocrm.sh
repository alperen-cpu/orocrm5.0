clear
echo "===================== OroCRM Sample Application 5.0 Installation https://github.com/oroinc/crm-application ====================="
echo "===================== Author: Alperen Sah Abursum | github.com/alperen-cpu ====================="
echo "==================================== START ===================================="
apt-get install sudo zlib1g zlib1g-dev libgd-dev libxml2 libxml2-dev uuid-dev curl libpcre3 libpcre3-dev libssl-dev openssl ca-certificates apt-transport-https software-properties-common wget curl lsb-release gnupg2 unzip build-essential -y
echo "==================================== Nginx 1.23.0 START ===================================="
#https://www.nginx.com/resources/wiki/start/topics/tutorials/install/
#https://nginx.org/en/linux_packages.html#Debian
curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor \
    | sudo tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null

gpg --dry-run --quiet --import --import-options import-show /usr/share/keyrings/nginx-archive-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] \
http://nginx.org/packages/debian `lsb_release -cs` nginx" \
    | sudo tee /etc/apt/sources.list.d/nginx.list


echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" \
    | sudo tee /etc/apt/preferences.d/99nginx    
apt update
apt install nginx -y
systemctl stop nginx
#nginxsettings.txt >> /etc/nginx/conf.d/default.conf
echo "==================================== Nginx 1.23.0 FINISH ===================================="
echo "==================================== PHP 8.1 INSTALL START ===================================="
apt update
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/sury-php.list
wget -qO - https://packages.sury.org/php/apt.gpg | sudo apt-key add -
apt update
apt install php8.1 -y
apt install php8.1-bcmath php8.1-common php8.1-curl php8.1-fpm php8.1-gd php8.1-imap php8.1-intl php8.1-ldap php8.1-mbstring php8.1-mysql php8.1-mongodb php8.1-opcache php8.1-soap php8.1-tidy php8.1-xml php8.1-zip -y
rm -rf /usr/lib/apache2 /usr/lib/php/8.1/sapi/apache2 /usr/share/apache2 /usr/sbin/apache2 /etc/apache2 /etc/php/8.1/apache2 /var/lib/apache2 /var/lib/php/modules/8.1/apache2
apt autoremove apache2 -y
apt purge apache2 -y
apt remove apache2 -y
echo "==================================== PHP INSTALL FINISH ===================================="
echo "==================================== PHP SETTINGS START ===================================="
sed -i 's#;date.timezone =#date.timezone = Europe/Istanbul#' /etc/php/8.1/fpm/php.ini
sed -i 's#;date.timezone =#date.timezone = Europe/Istanbul#' /etc/php/8.1/cli/php.ini
sed -i 's/memory_limit = 128M/memory_limit = 1G/' /etc/php/8.1/fpm/php.ini
sed -i 's/max_execution_time = 30/max_execution_time = 60/' /etc/php/8.1/fpm/php.ini
sed -i 's/max_execution_time = 30/max_execution_time = 60/' /etc/php/8.1/cli/php.ini
echo 'detect_unicode = Off' | tee -a /etc/php/8.1/fpm/php.ini
echo 'detect_unicode = Off' | tee -a /etc/php/8.1/cli/php.ini
sed -i 's/opcache.enable=1/opcache.enable=1/' /etc/php/8.1/fpm/php.ini
sed -i 's/opcache.enable_cli=0/opcache.enable_cli=0/' /etc/php/8.1/fpm/php.ini
sed -i 's/opcache.memory_consumption=128/opcache.memory_consumption=512/' /etc/php/8.1/fpm/php.ini
sed -i 's/opcache.max_accelerated_files=10000/opcache.max_accelerated_files=65407/' /etc/php/8.1/fpm/php.ini
sed -i 's/opcache.interned_strings_buffer=8/opcache.interned_strings_buffer=32/' /etc/php/8.1/fpm/php.ini
sed -i 's/realpath_cache_size=4096K/realpath_cache_size=4096K/' /etc/php/8.1/fpm/php.ini
sed -i 's/realpath_cache_ttl = 120/realpath_cache_ttl=600/' /etc/php/8.1/fpm/php.ini
sed -i 's/opcache.save_comments=1/opcache.save_comments=1/' /etc/php/8.1/fpm/php.ini
sed -i 's/opcache.validate_timestamps=1/opcache.validate_timestamps=0/' /etc/php/8.1/fpm/php.ini
sed -i 's/opcache.enable_cli=0/opcache.enable_cli=0/' /etc/php/8.1/cli/php.ini
sed -i 's/pm.max_children = 5/pm.max_children = 128/' /etc/php/8.1/fpm/pool.d/www.conf
sed -i 's/pm.start_servers = 2/pm.start_servers = 8/' /etc/php/8.1/fpm/pool.d/www.conf
sed -i 's/pm.min_spare_servers = 1/pm.min_spare_servers = 4/' /etc/php/8.1/fpm/pool.d/www.conf
sed -i 's/pm.max_spare_servers = 3/pm.max_spare_servers = 8/' /etc/php/8.1/fpm/pool.d/www.conf
sed -i 's/;pm.max_requests = 500/pm.max_requests = 512/' /etc/php/8.1/fpm/pool.d/www.conf
sed -i 's/;catch_workers_output = yes/catch_workers_output = yes/' /etc/php/8.1/fpm/pool.d/www.conf
systemctl start php8.1-fpm.service
/lib/systemd/systemd-sysv-install enable php8.1-fpm
systemctl enable php8.1-fpm.service
echo "==================================== PHP SETTINGS FINISH ===================================="
echo "==================================== PHP COMPOSER START ===================================="
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php -r "if (hash_file('sha384', 'composer-setup.php') === '55ce33d7678c5a611085589f1f3ddf8b3c52d662cd01d4ba75c0ee0459970c2200a51f492d557530c71c15d8dba01eae') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;"
php composer-setup.php
php -r "unlink('composer-setup.php');"
mv composer.phar /usr/local/bin/composer
echo "==================================== PHP COMPOSER FINISH ===================================="
echo "==================================== NODE v16 START ===================================="
curl -sL https://deb.nodesource.com/setup_16.x | bash -
apt update -y
apt-get install -y nodejs
npm -v && node -v
echo "==================================== NODE FINISH ===================================="
echo "==================================== Supervisor START ===================================="
apt update
apt install python3 python3-pip -y
pip install setuptools
pip install supervisor
echo "==================================== Supervisor FINISH ===================================="
echo "==================================== MySQL 8.0.29 START ===================================="
#https://computingforgeeks.com/how-to-install-mysql-8-0-on-debian/
wget https://repo.mysql.com//mysql-apt-config_0.8.22-1_all.deb
dpkg -i mysql-apt-config_0.8.22-1_all.deb
apt update
apt install mysql-server -y
read -p "Enter Root Password : " rootpass
mysql --user=root --password=$rootpass -e "CREATE DATABASE orodb;use orodb;CREATE USER 'orouser'@'localhost' IDENTIFIED BY 'SxdS9NpKKuZU';GRANT ALL PRIVILEGES ON orodb.* TO orouser@'localhost';FLUSH PRIVILEGES;"
echo "==================================== MySQL FINISH ===================================="
echo "==================================== APP START ===================================="
echo "==================================== APP FINISH ===================================="
