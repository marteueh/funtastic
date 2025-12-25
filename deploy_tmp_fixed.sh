#!/bin/bash

# Script di deploy SENZA SUDO per FUNTASTING - Tutto in /tmp
# Esegui con: bash deploy_tmp_fixed.sh

set -e

echo "🚀 Deploy FUNTASTING (Tutto in /tmp)"
echo "====================================="

# Colori
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Usa /tmp per tutto
APP_DIR="/tmp/funtasting"
COMPOSER_DIR="/tmp/composer"
NVM_DIR="/tmp/.nvm"

echo -e "${GREEN}Installazione in: $APP_DIR${NC}"

# 1. Verifica che siamo nella directory giusta
echo -e "${GREEN}[1/9] Verifica directory...${NC}"
if [ ! -f "$APP_DIR/composer.json" ]; then
    echo -e "${RED}Errore: Devi essere in /tmp/funtasting${NC}"
    echo -e "${YELLOW}Esegui: cd /tmp/funtasting${NC}"
    exit 1
fi

cd $APP_DIR

# 2. Verifica PHP
echo -e "${GREEN}[2/9] Verifica PHP...${NC}"
if ! command -v php &> /dev/null; then
    echo -e "${RED}PHP non trovato. Devi installarlo manualmente o chiedere al provider.${NC}"
    exit 1
else
    PHP_VERSION=$(php -v | head -n 1)
    echo -e "${GREEN}PHP trovato: $PHP_VERSION${NC}"
fi

# 3. Installa Composer in /tmp
echo -e "${GREEN}[3/9] Installazione Composer...${NC}"
if ! command -v composer &> /dev/null; then
    cd /tmp
    curl -sS https://getcomposer.org/installer | php
    mkdir -p $COMPOSER_DIR
    mv composer.phar $COMPOSER_DIR/composer
    chmod +x $COMPOSER_DIR/composer
    export PATH="$COMPOSER_DIR:$PATH"
    echo -e "${GREEN}Composer installato in $COMPOSER_DIR${NC}"
else
    echo -e "${GREEN}Composer già installato${NC}"
    export PATH="$COMPOSER_DIR:$PATH"
fi

# 4. Installa Node.js in /tmp
echo -e "${GREEN}[4/9] Installazione Node.js...${NC}"
if ! command -v node &> /dev/null; then
    cd /tmp
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | NVM_DIR=$NVM_DIR bash
    export NVM_DIR="$NVM_DIR"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install 20
    nvm use 20
    echo -e "${GREEN}Node.js installato in $NVM_DIR${NC}"
else
    echo -e "${GREEN}Node.js già installato${NC}"
    export NVM_DIR="$NVM_DIR"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
fi

# 5. Torna alla directory del progetto
cd $APP_DIR

# 6. Installa dipendenze
echo -e "${GREEN}[6/9] Installazione dipendenze...${NC}"

# Assicurati che PATH sia corretto
export PATH="$COMPOSER_DIR:$PATH"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Verifica che composer e npm siano disponibili
if ! command -v composer &> /dev/null; then
    echo -e "${RED}Composer non trovato nel PATH${NC}"
    echo -e "${YELLOW}Usa: $COMPOSER_DIR/composer${NC}"
    $COMPOSER_DIR/composer install --optimize-autoloader --no-dev
else
    composer install --optimize-autoloader --no-dev
fi

if ! command -v npm &> /dev/null; then
    echo -e "${RED}npm non trovato nel PATH${NC}"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh" && npm install && npm run build
else
    npm install
    npm run build
fi

# 7. Configura .env
echo -e "${GREEN}[7/9] Configurazione .env...${NC}"
if [ ! -f "$APP_DIR/.env" ]; then
    cp .env.example .env
    
    # Genera APP_KEY
    php artisan key:generate --no-interaction
    
    # Usa SQLite per semplicità
    echo -e "${YELLOW}Configurazione con SQLite${NC}"
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
echo -e "${GREEN}[8/9] Setup Laravel...${NC}"
php artisan migrate --force
php artisan db:seed --force
php artisan storage:link
php artisan config:cache
php artisan route:cache
php artisan view:cache

# 9. Crea script di avvio
echo -e "${GREEN}[9/9] Creazione script di avvio...${NC}"
cat > /tmp/start_funtasting.sh << 'EOFSCRIPT'
#!/bin/bash
export PATH="/tmp/composer:$PATH"
export NVM_DIR="/tmp/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
cd /tmp/funtasting
php artisan serve --host=0.0.0.0 --port=8000
EOFSCRIPT
chmod +x /tmp/start_funtasting.sh

echo -e "${GREEN}✅ Deploy completato!${NC}"
echo ""
echo -e "${YELLOW}Per avviare il server:${NC}"
echo "bash /tmp/start_funtasting.sh"
echo ""
echo -e "${YELLOW}Oppure manualmente:${NC}"
echo "export PATH=\"/tmp/composer:\$PATH\""
echo "export NVM_DIR=\"/tmp/.nvm\""
echo "[ -s \"\$NVM_DIR/nvm.sh\" ] && \. \"\$NVM_DIR/nvm.sh\""
echo "cd /tmp/funtasting"
echo "php artisan serve --host=0.0.0.0 --port=8000"
echo ""
echo -e "${YELLOW}Il sito sarà disponibile su: http://217.114.212.10:8000${NC}"

