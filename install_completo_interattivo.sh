#!/bin/bash

# Script di installazione completa e interattiva FUNTASTING
# Esegui con: bash install_completo_interattivo.sh

set -e

# Colori
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  INSTALLAZIONE FUNTASTING LARAVEL 12  ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# ============================================
# RACCOLTA INFORMAZIONI
# ============================================

echo -e "${YELLOW}📋 RACCOLTA INFORMAZIONI${NC}"
echo -e "${YELLOW}─────────────────────────────────────${NC}"
echo ""

# 1. Directory di installazione
read -p "Directory di installazione [/var/www/funtasting]: " INSTALL_DIR
INSTALL_DIR=${INSTALL_DIR:-/var/www/funtasting}
echo -e "${GREEN}✓ Directory: $INSTALL_DIR${NC}"
echo ""

# 2. Dominio/URL
read -p "Dominio del sito (es. funtasting.com): " DOMAIN
if [ -z "$DOMAIN" ]; then
    echo -e "${RED}ERRORE: Dominio richiesto!${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Dominio: $DOMAIN${NC}"
echo ""

# 3. Database - Host
read -p "Database Host [127.0.0.1]: " DB_HOST
DB_HOST=${DB_HOST:-127.0.0.1}
echo -e "${GREEN}✓ DB Host: $DB_HOST${NC}"

# 4. Database - Nome
read -p "Nome Database [funtasting]: " DB_NAME
DB_NAME=${DB_NAME:-funtasting}
echo -e "${GREEN}✓ DB Name: $DB_NAME${NC}"

# 5. Database - Utente
read -p "Database Username [funtasting_user]: " DB_USER
DB_USER=${DB_USER:-funtasting_user}
echo -e "${GREEN}✓ DB User: $DB_USER${NC}"

# 6. Database - Password
read -sp "Database Password: " DB_PASS
echo ""
if [ -z "$DB_PASS" ]; then
    echo -e "${RED}ERRORE: Password database richiesta!${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Password configurata${NC}"
echo ""

# 7. Utente web server
read -p "Utente web server [www-data]: " WEB_USER
WEB_USER=${WEB_USER:-www-data}
echo -e "${GREEN}✓ Web User: $WEB_USER${NC}"
echo ""

# 8. MySQL root password (per creare database)
read -sp "MySQL Root Password (lascia vuoto se non serve): " MYSQL_ROOT_PASS
echo ""
echo ""

# 9. Configurare Nginx automaticamente?
read -p "Configurare Nginx automaticamente? (s/n) [s]: " CONFIGURE_NGINX
CONFIGURE_NGINX=${CONFIGURE_NGINX:-s}
echo ""

# ============================================
# VERIFICA PREREQUISITI
# ============================================

echo -e "${YELLOW}🔍 VERIFICA PREREQUISITI${NC}"
echo -e "${YELLOW}─────────────────────────────────────${NC}"

# PHP 8.2+
echo -e "${GREEN}[1/6] Verifica PHP...${NC}"
if ! command -v php &> /dev/null; then
    echo -e "${RED}ERRORE: PHP non trovato!${NC}"
    exit 1
fi
PHP_VERSION=$(php -v | head -n 1 | cut -d " " -f 2 | cut -d "." -f 1,2)
PHP_MAJOR=$(echo $PHP_VERSION | cut -d "." -f 1)
PHP_MINOR=$(echo $PHP_VERSION | cut -d "." -f 2)
if [ "$PHP_MAJOR" -lt 8 ] || ([ "$PHP_MAJOR" -eq 8 ] && [ "$PHP_MINOR" -lt 2 ]); then
    echo -e "${RED}ERRORE: PHP 8.2+ richiesto. Versione trovata: $PHP_VERSION${NC}"
    exit 1
fi
echo -e "${GREEN}✓ PHP $PHP_VERSION trovato${NC}"

# Composer
echo -e "${GREEN}[2/6] Verifica Composer...${NC}"
if ! command -v composer &> /dev/null; then
    echo -e "${YELLOW}Composer non trovato. Installazione...${NC}"
    curl -sS https://getcomposer.org/installer | php
    sudo mv composer.phar /usr/local/bin/composer
    sudo chmod +x /usr/local/bin/composer
fi
echo -e "${GREEN}✓ Composer installato${NC}"

# Node.js
echo -e "${GREEN}[3/6] Verifica Node.js...${NC}"
if ! command -v node &> /dev/null; then
    echo -e "${YELLOW}Node.js non trovato. Installazione...${NC}"
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt install -y nodejs
fi
echo -e "${GREEN}✓ Node.js $(node -v) installato${NC}"

# MySQL
echo -e "${GREEN}[4/6] Verifica MySQL...${NC}"
if ! command -v mysql &> /dev/null; then
    echo -e "${RED}ERRORE: MySQL non trovato!${NC}"
    exit 1
fi
echo -e "${GREEN}✓ MySQL installato${NC}"

# Git
echo -e "${GREEN}[5/6] Verifica Git...${NC}"
if ! command -v git &> /dev/null; then
    echo -e "${YELLOW}Git non trovato. Installazione...${NC}"
    sudo apt update
    sudo apt install -y git
fi
echo -e "${GREEN}✓ Git installato${NC}"

# Nginx
if [ "$CONFIGURE_NGINX" = "s" ]; then
    echo -e "${GREEN}[6/6] Verifica Nginx...${NC}"
    if ! command -v nginx &> /dev/null; then
        echo -e "${YELLOW}Nginx non trovato. Installazione...${NC}"
        sudo apt update
        sudo apt install -y nginx
    fi
    echo -e "${GREEN}✓ Nginx installato${NC}"
fi

echo ""

# ============================================
# INSTALLAZIONE PROGETTO
# ============================================

echo -e "${YELLOW}📦 INSTALLAZIONE PROGETTO${NC}"
echo -e "${YELLOW}─────────────────────────────────────${NC}"

# Crea directory
echo -e "${GREEN}[1/10] Creazione directory...${NC}"
sudo mkdir -p "$(dirname $INSTALL_DIR)"
if [ -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}Directory esistente. Aggiornamento...${NC}"
    cd "$INSTALL_DIR"
    sudo git pull origin main || echo -e "${YELLOW}Git pull fallito, continuo...${NC}"
else
    echo -e "${GREEN}Clonazione repository...${NC}"
    sudo git clone https://github.com/marteueh/funtastic.git "$INSTALL_DIR"
fi
cd "$INSTALL_DIR"
echo -e "${GREEN}✓ Directory pronta${NC}"

# Installa dipendenze Composer
echo -e "${GREEN}[2/10] Installazione dipendenze PHP...${NC}"
sudo composer install --optimize-autoloader --no-dev --no-interaction
echo -e "${GREEN}✓ Dipendenze PHP installate${NC}"

# Configura .env
echo -e "${GREEN}[3/10] Configurazione .env...${NC}"
if [ ! -f .env ]; then
    sudo cp .env.example .env 2>/dev/null || sudo cp .env .env.backup 2>/dev/null || true
    
    # Genera APP_KEY
    sudo php artisan key:generate --force
    
    # Configura .env
    sudo sed -i "s|APP_NAME=.*|APP_NAME=\"FUNTASTING\"|" .env
    sudo sed -i "s|APP_ENV=.*|APP_ENV=production|" .env
    sudo sed -i "s|APP_DEBUG=.*|APP_DEBUG=false|" .env
    sudo sed -i "s|APP_URL=.*|APP_URL=https://$DOMAIN|" .env
    
    sudo sed -i "s|DB_CONNECTION=.*|DB_CONNECTION=mysql|" .env
    sudo sed -i "s|DB_HOST=.*|DB_HOST=$DB_HOST|" .env
    sudo sed -i "s|DB_PORT=.*|DB_PORT=3306|" .env
    sudo sed -i "s|DB_DATABASE=.*|DB_DATABASE=$DB_NAME|" .env
    sudo sed -i "s|DB_USERNAME=.*|DB_USERNAME=$DB_USER|" .env
    sudo sed -i "s|DB_PASSWORD=.*|DB_PASSWORD=$DB_PASS|" .env
    
    sudo sed -i "s|LOG_LEVEL=.*|LOG_LEVEL=error|" .env
    sudo sed -i "s|SESSION_DRIVER=.*|SESSION_DRIVER=database|" .env
    
    echo -e "${GREEN}✓ File .env configurato${NC}"
else
    echo -e "${GREEN}✓ File .env già esistente${NC}"
fi

# Crea database
echo -e "${GREEN}[4/10] Creazione database...${NC}"
if [ -n "$MYSQL_ROOT_PASS" ]; then
    MYSQL_CMD="mysql -u root -p$MYSQL_ROOT_PASS"
else
    MYSQL_CMD="mysql -u root"
fi

$MYSQL_CMD <<EOF 2>/dev/null || true
CREATE DATABASE IF NOT EXISTS \`$DB_NAME\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
EOF

echo -e "${GREEN}✓ Database creato${NC}"

# Installa dipendenze npm
echo -e "${GREEN}[5/10] Installazione dipendenze Node.js...${NC}"
sudo npm install --silent
echo -e "${GREEN}✓ Dipendenze Node.js installate${NC}"

# Compila asset
echo -e "${GREEN}[6/10] Compilazione asset frontend...${NC}"
sudo npm run build
echo -e "${GREEN}✓ Asset compilati${NC}"

# Esegui migrazioni
echo -e "${GREEN}[7/10] Esecuzione migrazioni...${NC}"
sudo php artisan migrate --force
echo -e "${GREEN}✓ Migrazioni eseguite${NC}"

# Esegui seeder
echo -e "${GREEN}[8/10] Popolamento database...${NC}"
sudo php artisan db:seed --force
echo -e "${GREEN}✓ Database popolato${NC}"

# Crea link storage
echo -e "${GREEN}[9/10] Creazione link storage...${NC}"
sudo php artisan storage:link || echo -e "${YELLOW}Link storage già esistente${NC}"
echo -e "${GREEN}✓ Link storage creato${NC}"

# Imposta permessi
echo -e "${GREEN}[10/10] Impostazione permessi...${NC}"
sudo chown -R $WEB_USER:$WEB_USER "$INSTALL_DIR"
sudo chmod -R 755 "$INSTALL_DIR"
sudo chmod -R 775 "$INSTALL_DIR/storage"
sudo chmod -R 775 "$INSTALL_DIR/bootstrap/cache"
echo -e "${GREEN}✓ Permessi impostati${NC}"

# Ottimizza cache
echo -e "${GREEN}Ottimizzazione cache...${NC}"
sudo php artisan config:cache
sudo php artisan route:cache
sudo php artisan view:cache
echo -e "${GREEN}✓ Cache ottimizzata${NC}"

echo ""

# ============================================
# CONFIGURAZIONE NGINX
# ============================================

if [ "$CONFIGURE_NGINX" = "s" ]; then
    echo -e "${YELLOW}🌐 CONFIGURAZIONE NGINX${NC}"
    echo -e "${YELLOW}─────────────────────────────────────${NC}"
    
    NGINX_CONFIG="/etc/nginx/sites-available/funtasting"
    
    echo -e "${GREEN}Creazione configurazione Nginx...${NC}"
    sudo tee "$NGINX_CONFIG" > /dev/null <<EOF
server {
    listen 80;
    listen [::]:80;
    server_name $DOMAIN www.$DOMAIN;
    root $INSTALL_DIR/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php;

    charset utf-8;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php${PHP_VERSION}-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
EOF
    
    # Abilita sito
    sudo ln -sf "$NGINX_CONFIG" /etc/nginx/sites-enabled/
    
    # Rimuovi default se esiste
    sudo rm -f /etc/nginx/sites-enabled/default
    
    # Test configurazione
    echo -e "${GREEN}Test configurazione Nginx...${NC}"
    sudo nginx -t
    
    # Riavvia Nginx
    echo -e "${GREEN}Riavvio Nginx...${NC}"
    sudo systemctl restart nginx
    
    echo -e "${GREEN}✓ Nginx configurato${NC}"
    echo ""
fi

# ============================================
# RIEPILOGO
# ============================================

echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     ✅ INSTALLAZIONE COMPLETATA!      ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}📋 RIEPILOGO CONFIGURAZIONE:${NC}"
echo -e "${BLUE}─────────────────────────────────────${NC}"
echo -e "Directory: ${GREEN}$INSTALL_DIR${NC}"
echo -e "Dominio: ${GREEN}$DOMAIN${NC}"
echo -e "Database: ${GREEN}$DB_NAME${NC}"
echo -e "Utente DB: ${GREEN}$DB_USER${NC}"
echo ""
echo -e "${YELLOW}🔐 CREDENZIALI ACCESSO:${NC}"
echo -e "${YELLOW}─────────────────────────────────────${NC}"
echo -e "Admin: ${GREEN}admin@funtasting.it${NC} / ${GREEN}password${NC}"
echo -e "Vendor: ${GREEN}vendor@funtasting.it${NC} / ${GREEN}password${NC}"
echo -e "Reseller: ${GREEN}reseller@funtasting.it${NC} / ${GREEN}password${NC}"
echo -e "Customer: ${GREEN}customer@funtasting.it${NC} / ${GREEN}password${NC}"
echo ""
if [ "$CONFIGURE_NGINX" = "s" ]; then
    echo -e "${YELLOW}🌐 PROSSIMI PASSI:${NC}"
    echo -e "${YELLOW}─────────────────────────────────────${NC}"
    echo -e "1. Configura DNS per puntare $DOMAIN al tuo server"
    echo -e "2. Installa certificato SSL:"
    echo -e "   ${GREEN}sudo apt install certbot python3-certbot-nginx${NC}"
    echo -e "   ${GREEN}sudo certbot --nginx -d $DOMAIN -d www.$DOMAIN${NC}"
    echo -e "3. Visita: ${GREEN}http://$DOMAIN${NC}"
else
    echo -e "${YELLOW}🌐 Configura manualmente il tuo web server${NC}"
    echo -e "   Document root: ${GREEN}$INSTALL_DIR/public${NC}"
fi
echo ""
echo -e "${GREEN}✅ Tutto pronto!${NC}"
echo ""

