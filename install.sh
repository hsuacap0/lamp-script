#!/usr/bin/bash
DEBIAN_FRONTEND=noninteractive
line="\$nrconf{restart} = 'a'"
if ! grep -qF "$line" /etc/needrestart/needrestart.conf; then
    # If the line doesn't exist, append it to the file
    echo "$line" >> /etc/needrestart/needrestart.conf
fi
YELLOW='\033[1;33m'
NC='\033[0m'
GREEN='\033[1;32m'
RED='\033[1;31m'

show_loading() {
    local pid=$1
    local delay=0.1
    local spin='-\|/'

    while kill -0 $pid 2>/dev/null; do
        printf "%c" "${spin:i++%${#spin}:1}"
        sleep $delay
        printf "\b"
    done
}

user_input() {
    printf "${YELLOW}[*]${NC} Please enter your desired MySQL root crendentials:${NC} "
    read -s secret
    echo ""
    printf "${YELLOW}[*]${NC} Please enter the PHP versions that you would like to install: "
    read php
}

system_update() {
    echo -e "${YELLOW}[*]${NC} Starting system update..."
    sleep 2
    apt update -y >/dev/null 2>&1 &
    local pid=$!
    show_loading $pid
    wait $pid
    if [ $? -ne 0 ]; then
        echo -e "${RED}[*]${NC} Error"
    else
        echo -e "${GREEN}[*]${NC} OK"
    fi
}

nginx () {
    echo -e "${YELLOW}[*]${NC} Installing nginx..."
    sleep 2
    add-apt-repository ppa:ondrej/nginx -y >/dev/null 2>&1 &
    apt update -y  >/dev/null 2>&1 &
    apt install zip nginx -y  >/dev/null 2>&1 &
    local pid=$!
    show_loading $pid
    wait $pid
    if [ $? -ne 0 ]; then
        echo -e "${RED}[*]${NC} Error"
    else
        echo -e "${GREEN}[*]${NC} OK"
    fi
}

php () {
    echo -e "${YELLOW}[*]${NC} Installing PHP Version: $php"
    sleep 2
    add-apt-repository ppa:ondrej/php -y >/dev/null 2>&1 &
    apt update -y >/dev/null 2>&1 &
    apt install php$php-fpm php$php-mysql php$php-zip php$php-mbstring php$php-xml php$php-curl php$php-gd php$php-bcmath -y >/dev/null 2>&1 &
    local pid=$!
    show_loading $pid
    wait $pid
    if [ $? -ne 0 ]; then
        echo -e "${RED}[*]${NC} Error"
    else
        echo -e "${GREEN}[*]${NC} OK"
    fi
}

certbot () {
    echo -e "${YELLOW}[*]${NC} Installing certbot via Snap..."
    sleep 2
    apt install snap -y >/dev/null 2>&1 &
    snap install certbot --classic >/dev/null 2>&1 &
    local pid=$!
    show_loading $pid
    wait $pid
    if [ $? -ne 0 ]; then
        echo -e "${RED}[*]${NC} Error"
    else
        echo -e "${GREEN}[*]${NC} OK"
    fi
}

mysql_install () {
    echo -e "${YELLOW}[*]${NC} Installing MySQL..."
    sleep 2
    apt install mysql-server -y >/dev/null 2>&1 &
    local pid=$!
    show_loading $pid
    wait $pid
    if [ $? -ne 0 ]; then
        echo -e "${RED}[*]${NC} Error"
    else
        echo -e "${GREEN}[*]${NC} OK"
    fi
}

mysql_reset () {
    echo -e "${YELLOW}[*]${NC} Resetting MySQL root password and disable passwordless login"
    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$secret';" >/dev/null 2>&1 &
    local pid=$!
    show_loading $pid
    wait $pid
    if [ $? -ne 0 ]; then
        echo -e "${RED}[*]${NC} Error"
    else
        echo -e "${GREEN}[*]${NC} OK"
    fi
}

idone () {
    echo -e "${YELLOW}[*]${NC} LAMP Installation completed!"
    echo -e "${YELLOW}[*]${NC} Below are MySQL root crendentials..."
    echo -e "${YELLOW}[*]${NC} Secret: $secret"
}

user_input
system_update
nginx
php
certbot
mysql_install
mysql_reset
idone