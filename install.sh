#!/bin/bash

user_input() {
intf "%s" "Please enter your desired MySQL root crendentials: "
    read -s secret
    echo ""
    printf "%s" "Please enter the PHP versions that you would like to install: "
    read php
}

system_update() {
    echo "Starting system update..."
    sleep 5
    apt update -y
    apt upgrade -y 
    echo ""
}

nginx () {
    echo "Installing nginx..."
    sleep 5
    add-apt-repository ppa:ondrej/nginx -y
    apt update -y
    apt install zip nginx -y
}

php () {
    echo "Installing PHP Version: $php"
    sleep 5
    add-apt-repository ppa:ondrej/php -y
    apt update -y
    apt install php$php-fpm php$php-mysql php$php-zip php$php-mbstring php$php-xml php$php-curl php$php-gd php$php-bcmath -y
}

certbot () {
    echo "Installing certbot via Snap..."
    sleep 5
    apt install snap -y
    snap install certbot --classic
}

mysql () {
    echo "Installing MySQL..."
    sleep 5
    apt install mysql-server -y
    echo "Resetting MySQL root password and disable passwordless login"
    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'pass';"
    expect -c "
spawn mysql_secure_installation
expect \"Enter current password for root (enter for none):\"
send \"pass\r\"
expect \"Set root password?\"
send \"Y\r\"
expect \"New password:\"
send \"$secret\r\"
expect \"Re-enter new password:\"
send \"$secret\r\"
expect \"Remove anonymous users?\"
send \"Y\r\"
expect \"Disallow root login remotely?\"
send \"Y\r\"
expect \"Remove test database and access to it?\"
send \"Y\r\"
expect \"Reload privilege tables now?\"
send \"Y\r\"
interact
"

}

done () {
    echo "LAMP Installation completed!"
    echo "Below are MySQL root crendentials..."
    echo "Secret: $secret"
}

user_input
system_update
nginx
php
certbot
mysql