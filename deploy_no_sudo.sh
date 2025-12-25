#!/bin/bash

# Script di deploy SENZA SUDO per FUNTASTING
# Esegui con: bash deploy_no_sudo.sh

set -e

echo "🚀 Deploy FUNTASTING (Senza Sudo)"
echo "=================================="

# Colori
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

USER_HOME=$HOME
APP_DIR="$USER_HOME/funtasting"
PHP_DIR="$USER_HOME/php"
COMPOSER_DIR="$USER_HOME/.composer"
NODE_DIR="$USER_HOME/.node"

echo -e "${GREEN}Installazione in: $APP_DIR${NC}"

# 1. Crea directory
echo -e "${GREEN}[1/8] Creazione directory...${NC}"
mkdir -p $APP_DIR
mkdir -p $PHP_DIR
mkdir -p $COMPOSER_DIR
mkdir -p $NODE_DIR

# 2. Verifica PHP
echo -e "${GREEN}[2/8] Verifica PHP...${NC}"
if ! command -v php &> /dev/null; then
    echo -e "${RED}PHP non trovato. Devi installarlo manualmente o chiedere al provider.${NC}"
    echo -e "${YELLOW}Prova: which php${NC}"
    exit 1
else
    PHP_VERSION=$(php -v | head -n 1)
    echo -e "${GREEN}PHP trovato: $PHP_VERSION${NC}"
fi

# 3. Installa Composer (locale)
echo -e "${GREEN}[3/8] Installazione Composer...${NC}"
if ! command -v composer &> /dev/null; then
    cd $USER_HOME
    curl -sS https://getcomposer.org/installer | php
    mv composer.phar $COMPOSER_DIR/composer
    chmod +x $COMPOSER_DIR/composer
    export PATH="$COMPOSER_DIR:$PATH"
    echo 'export PATH="$HOME/.composer:$PATH"' >> ~/.bashrc
else
    echo -e "${GREEN}Composer già installato${NC}"
fi

# 4. Installa Node.js (locale via nvm)
echo -e "${GREEN}[4/8] Installazione Node.js...${NC}"
if ! command -v node &> /dev/null; then
    cd $USER_HOME
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install 20
    nvm use 20
    echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc
else
    echo -e "${GREEN}Node.js già installato${NC}"
fi

# 5. Clona repository
echo -e "${GREEN}[5/8] Clonazione repository...${NC}"
if [ ! -d "$APP_DIR/.git" ]; then
    cd $USER_HOME
    git clone https://github.com/marteueh/funtastic.git funtasting
else
    cd $APP_DIR
    git pull
fi

# 6. Installa dipendenze
echo -e "${GREEN}[6/8] Installazione dipendenze...${NC}"
cd $APP_DIR

# Carica variabili d'ambiente
export PATH="$HOME/.composer:$PATH"
[ -s "$HOME/.nvm/nvm.sh" ] && \. "$HOME/.nvm/nvm.sh"

composer install --optimize-autoloader --no-dev
npm install
npm run build

# 7. Configura .env
echo -e "${GREEN}[7/8] Configurazione .env...${NC}"
if [ ! -f "$APP_DIR/.env" ]; then
    cp .env.example .env
    
    # Genera APP_KEY
    php artisan key:generate --no-interaction
    
    # Configura database (usa SQLite per semplicità se MySQL non disponibile)
    read -p "Vuoi usare SQLite? (s/n) [s]: " USE_SQLITE
    USE_SQLITE=${USE_SQLITE:-s}
    
    if [ "$USE_SQLITE" = "s" ]; then
        sed -i "s/DB_CONNECTION=.*/DB_CONNECTION=sqlite/" .env
        sed -i "s/DB_DATABASE=.*/DB_DATABASE=\/\/database\/database.sqlite/" .env
        touch database/database.sqlite
        chmod 664 database/database.sqlite
    else
        echo -e "${YELLOW}Configurazione Database MySQL:${NC}"
        read -p "DB_HOST [127.0.0.1]: " DB_HOST
        DB_HOST=${DB_HOST:-127.0.0.1}
        read -p "DB_PORT [3306]: " DB_PORT
        DB_PORT=${DB_PORT:-3306}
        read -p "DB_DATABASE: " DB_DATABASE
        read -p "DB_USERNAME: " DB_USERNAME
        read -sp "DB_PASSWORD: " DB_PASSWORD
        echo ""
        
        sed -i "s/DB_HOST=.*/DB_HOST=$DB_HOST/" .env
        sed -i "s/DB_PORT=.*/DB_PORT=$DB_PORT/" .env
        sed -i "s/DB_DATABASE=.*/DB_DATABASE=$DB_DATABASE/" .env
        sed -i "s/DB_USERNAME=.*/DB_USERNAME=$DB_USERNAME/" .env
        sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=$DB_PASSWORD/" .env
    fi
    
    sed -i "s/APP_ENV=.*/APP_ENV=production/" .env
    sed -i "s/APP_DEBUG=.*/APP_DEBUG=false/" .env
    sed -i "s|APP_URL=.*|APP_URL=http://217.114.212.10|" .env
fi

# 8. Setup Laravel
echo -e "${GREEN}[8/8] Setup Laravel...${NC}"
php artisan migrate --force
php artisan db:seed --force
php artisan storage:link
php artisan config:cache
php artisan route:cache
php artisan view:cache

echo -e "${GREEN}✅ Deploy completato!${NC}"
echo ""
echo -e "${YELLOW}Per avviare il server:${NC}"
echo "cd $APP_DIR"
echo "php artisan serve --host=0.0.0.0 --port=8000"
echo ""
echo -e "${YELLOW}Il sito sarà disponibile su: http://217.114.212.10:8000${NC}"
echo ""
echo -e "${YELLOW}Per mantenerlo sempre attivo, usa screen o tmux:${NC}"
echo "screen -S funtasting"
echo "php artisan serve --host=0.0.0.0 --port=8000"
echo "# Premi Ctrl+A poi D per staccarti"
echo "# Per riattaccarti: screen -r funtasting"

