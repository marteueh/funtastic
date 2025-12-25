#!/bin/bash

# Script di deploy SENZA SUDO per FUNTASTING - Versione /tmp
# Esegui con: bash deploy_tmp.sh

set -e

echo "🚀 Deploy FUNTASTING (Senza Sudo - /tmp)"
echo "========================================="

# Colori
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Usa /tmp invece della home
APP_DIR="/tmp/funtasting"
COMPOSER_DIR="$HOME/.composer"
NODE_DIR="$HOME/.nvm"

echo -e "${GREEN}Installazione in: $APP_DIR${NC}"

# 1. Verifica che siamo nella directory giusta
echo -e "${GREEN}[1/8] Verifica directory...${NC}"
if [ ! -f "$APP_DIR/composer.json" ]; then
    echo -e "${RED}Errore: Devi essere in /tmp/funtasting${NC}"
    echo -e "${YELLOW}Esegui: cd /tmp/funtasting${NC}"
    exit 1
fi

cd $APP_DIR

# 2. Verifica PHP
echo -e "${GREEN}[2/8] Verifica PHP...${NC}"
if ! command -v php &> /dev/null; then
    echo -e "${RED}PHP non trovato. Devi installarlo manualmente o chiedere al provider.${NC}"
    exit 1
else
    PHP_VERSION=$(php -v | head -n 1)
    echo -e "${GREEN}PHP trovato: $PHP_VERSION${NC}"
fi

# 3. Installa Composer (locale)
echo -e "${GREEN}[3/8] Installazione Composer...${NC}"
if ! command -v composer &> /dev/null; then
    cd /tmp
    curl -sS https://getcomposer.org/installer | php
    mkdir -p $COMPOSER_DIR
    mv composer.phar $COMPOSER_DIR/composer
    chmod +x $COMPOSER_DIR/composer
    export PATH="$COMPOSER_DIR:$PATH"
    echo 'export PATH="$HOME/.composer:$PATH"' >> ~/.bashrc
    source ~/.bashrc
else
    echo -e "${GREEN}Composer già installato${NC}"
    export PATH="$HOME/.composer:$PATH"
fi

# 4. Installa Node.js (locale via nvm)
echo -e "${GREEN}[4/8] Installazione Node.js...${NC}"
if ! command -v node &> /dev/null; then
    cd /tmp
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install 20
    nvm use 20
    echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc
    source ~/.bashrc
else
    echo -e "${GREEN}Node.js già installato${NC}"
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
fi

# 5. Torna alla directory del progetto
cd $APP_DIR

# 6. Installa dipendenze
echo -e "${GREEN}[6/8] Installazione dipendenze...${NC}"

# Assicurati che PATH sia corretto
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
    
    # Usa SQLite per semplicità
    echo -e "${YELLOW}Configurazione con SQLite (più semplice)${NC}"
    sed -i "s/DB_CONNECTION=.*/DB_CONNECTION=sqlite/" .env
    sed -i "s|DB_DATABASE=.*|DB_DATABASE=$APP_DIR/database/database.sqlite|" .env
    sed -i "/DB_HOST/d" .env
    sed -i "/DB_PORT/d" .env
    sed -i "/DB_USERNAME/d" .env
    sed -i "/DB_PASSWORD/d" .env
    
    # Crea database SQLite
    touch database/database.sqlite
    chmod 664 database/database.sqlite
    
    sed -i "s/APP_ENV=.*/APP_ENV=production/" .env
    sed -i "s/APP_DEBUG=.*/APP_DEBUG=false/" .env
    sed -i "s|APP_URL=.*|APP_URL=http://217.114.212.10:8000|" .env
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
echo -e "${YELLOW}Per mantenerlo sempre attivo, usa screen:${NC}"
echo "screen -S funtasting"
echo "cd $APP_DIR"
echo "php artisan serve --host=0.0.0.0 --port=8000"
echo "# Premi Ctrl+A poi D per staccarti"
echo "# Per riattaccarti: screen -r funtasting"

