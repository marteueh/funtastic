#!/bin/bash

# Script di deploy automatico per FUNTASTING
# Esegui con: bash deploy.sh

set -e

echo "🚀 Deploy Automatico FUNTASTING"
echo "================================"

# Colori
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Verifica se è root
if [ "$EUID" -ne 0 ]; then 
    echo -e "${RED}Esegui con: sudo bash deploy.sh${NC}"
    exit 1
fi

# 1. Aggiorna sistema
echo -e "${GREEN}[1/10] Aggiornamento sistema...${NC}"
apt update && apt upgrade -y

# 2. Installa PHP 8.2
echo -e "${GREEN}[2/10] Installazione PHP 8.2...${NC}"
apt install -y software-properties-common
add-apt-repository ppa:ondrej/php -y
apt update
apt install -y php8.2 php8.2-fpm php8.2-cli php8.2-common \
    php8.2-mysql php8.2-zip php8.2-gd php8.2-mbstring \
    php8.2-curl php8.2-xml php8.2-bcmath php8.2-intl \
    php8.2-readline php8.2-tokenizer

# 3. Installa Composer
echo -e "${GREEN}[3/10] Installazione Composer...${NC}"
if ! command -v composer &> /dev/null; then
    curl -sS https://getcomposer.org/installer | php
    mv composer.phar /usr/local/bin/composer
    chmod +x /usr/local/bin/composer
fi

# 4. Installa Node.js
echo -e "${GREEN}[4/10] Installazione Node.js...${NC}"
if ! command -v node &> /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
    apt install -y nodejs
fi

# 5. Installa MySQL
echo -e "${GREEN}[5/10] Installazione MySQL...${NC}"
if ! command -v mysql &> /dev/null; then
    apt install -y mysql-server
fi

# 6. Installa Nginx
echo -e "${GREEN}[6/10] Installazione Nginx...${NC}"
if ! command -v nginx &> /dev/null; then
    apt install -y nginx
    systemctl enable nginx
    systemctl start nginx
fi

# 7. Clona repository
echo -e "${GREEN}[7/10] Clonazione repository...${NC}"
if [ ! -d "/var/www/funtastic" ]; then
    cd /var/www
    git clone https://github.com/marteueh/funtastic.git
    chown -R www-data:www-data funtastic
fi

# 8. Installa dipendenze
echo -e "${GREEN}[8/10] Installazione dipendenze...${NC}"
cd /var/www/funtastic
composer install --optimize-autoloader --no-dev
npm install
npm run build

# 9. Configura .env
echo -e "${GREEN}[9/10] Configurazione .env...${NC}"
if [ ! -f ".env" ]; then
    cp .env.example .env
    
    # Genera APP_KEY
    php artisan key:generate --no-interaction
    
    # Chiedi informazioni database
    echo -e "${YELLOW}Configurazione Database:${NC}"
    read -p "Database name [funtasting]: " DB_NAME
    DB_NAME=${DB_NAME:-funtasting}
    read -p "Database user [funtasting_user]: " DB_USER
    DB_USER=${DB_USER:-funtasting_user}
    read -sp "Database password: " DB_PASS
    echo ""
    
    # Crea database
    mysql -u root -e "CREATE DATABASE IF NOT EXISTS ${DB_NAME} CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
    mysql -u root -e "CREATE USER IF NOT EXISTS '${DB_USER}'@'localhost' IDENTIFIED BY '${DB_PASS}';"
    mysql -u root -e "GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'localhost';"
    mysql -u root -e "FLUSH PRIVILEGES;"
    
    # Aggiorna .env
    sed -i "s/DB_DATABASE=.*/DB_DATABASE=${DB_NAME}/" .env
    sed -i "s/DB_USERNAME=.*/DB_USERNAME=${DB_USER}/" .env
    sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=${DB_PASS}/" .env
    sed -i "s/APP_ENV=.*/APP_ENV=production/" .env
    sed -i "s/APP_DEBUG=.*/APP_DEBUG=false/" .env
fi

# 10. Setup Laravel
echo -e "${GREEN}[10/10] Setup Laravel...${NC}"
php artisan migrate --force
php artisan db:seed --force
php artisan storage:link
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Permessi
chown -R www-data:www-data /var/www/funtastic
chmod -R 755 /var/www/funtastic
chmod -R 775 /var/www/funtastic/storage
chmod -R 775 /var/www/funtastic/bootstrap/cache

# Configura Nginx
echo -e "${GREEN}Configurazione Nginx...${NC}"
cat > /etc/nginx/sites-available/funtastic << 'EOF'
server {
    listen 80;
    server_name _;
    root /var/www/funtastic/public;

    index index.php;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }
}
EOF

ln -sf /etc/nginx/sites-available/funtastic /etc/nginx/sites-enabled/
rm -f /etc/nginx/sites-enabled/default
nginx -t && systemctl reload nginx

echo -e "${GREEN}✅ Deploy completato!${NC}"
echo -e "${YELLOW}Il sito è disponibile su: http://$(hostname -I | awk '{print $1}')${NC}"

