#!/bin/bash

# Script di installazione automatica per FUNTASTING
# Esegui con: sudo bash script_install.sh

set -e

echo "🚀 Installazione FUNTASTING su Server"
echo "======================================"

# Colori
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Verifica se è root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Per favore esegui come root (sudo)${NC}"
    exit 1
fi

echo -e "${GREEN}1. Aggiornamento sistema...${NC}"
apt update && apt upgrade -y

echo -e "${GREEN}2. Installazione PHP 8.2...${NC}"
apt install -y software-properties-common
add-apt-repository ppa:ondrej/php -y
apt update
apt install -y php8.2 php8.2-fpm php8.2-cli php8.2-common \
    php8.2-mysql php8.2-zip php8.2-gd php8.2-mbstring \
    php8.2-curl php8.2-xml php8.2-bcmath php8.2-intl \
    php8.2-readline php8.2-tokenizer

echo -e "${GREEN}3. Installazione Composer...${NC}"
if ! command -v composer &> /dev/null; then
    curl -sS https://getcomposer.org/installer | php
    mv composer.phar /usr/local/bin/composer
    chmod +x /usr/local/bin/composer
fi

echo -e "${GREEN}4. Installazione Node.js...${NC}"
if ! command -v node &> /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
    apt install -y nodejs
fi

echo -e "${GREEN}5. Installazione MySQL...${NC}"
if ! command -v mysql &> /dev/null; then
    apt install -y mysql-server
fi

echo -e "${GREEN}6. Installazione Nginx...${NC}"
if ! command -v nginx &> /dev/null; then
    apt install -y nginx
    systemctl enable nginx
    systemctl start nginx
fi

echo -e "${GREEN}✅ Installazione base completata!${NC}"
echo ""
echo -e "${YELLOW}Prossimi passi manuali:${NC}"
echo "1. Trasferisci il progetto in /var/www/funtasting"
echo "2. Configura il database MySQL"
echo "3. Configura il file .env"
echo "4. Esegui: composer install && npm install && npm run build"
echo "5. Esegui: php artisan migrate --force"
echo "6. Configura Nginx (vedi DEPLOY_SERVER.md)"
echo ""
echo -e "${GREEN}Leggi DEPLOY_SERVER.md per i dettagli completi!${NC}"

