#!/bin/bash

# Script di installazione FUNTASTING - Versione Semplice
# Esegui con: bash install_semplice.sh

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

# Directory corrente
CURRENT_DIR=$(pwd)
echo -e "${YELLOW}Directory corrente: ${CURRENT_DIR}${NC}"
echo ""

# Chiedi dove installare
read -p "Dove vuoi installare il progetto? [$HOME/funtasting]: " INSTALL_DIR
INSTALL_DIR=${INSTALL_DIR:-$HOME/funtasting}
echo -e "${GREEN}✓ Installerò in: $INSTALL_DIR${NC}"
echo ""

# Crea directory se non esiste
echo -e "${GREEN}[1/8] Creazione directory...${NC}"
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"
echo -e "${GREEN}✓ Directory: $(pwd)${NC}"
echo ""

# Clona o aggiorna repository
echo -e "${GREEN}[2/8] Clonazione repository...${NC}"
if [ -d ".git" ]; then
    echo -e "${YELLOW}Repository già presente. Aggiornamento...${NC}"
    git pull origin main || echo -e "${YELLOW}Git pull fallito, continuo...${NC}"
else
    echo -e "${GREEN}Clonazione da GitHub...${NC}"
    git clone https://github.com/marteueh/funtastic.git .
fi
echo -e "${GREEN}✓ Repository pronto${NC}"
echo ""

# Verifica PHP
echo -e "${GREEN}[3/8] Verifica PHP...${NC}"
if ! command -v php &> /dev/null; then
    echo -e "${RED}ERRORE: PHP non trovato!${NC}"
    exit 1
fi
PHP_VERSION=$(php -v | head -n 1)
echo -e "${GREEN}✓ $PHP_VERSION${NC}"
echo ""

# Installa Composer (locale se necessario)
echo -e "${GREEN}[4/8] Verifica Composer...${NC}"
if command -v composer &> /dev/null; then
    COMPOSER_CMD="composer"
    echo -e "${GREEN}✓ Composer trovato${NC}"
else
    echo -e "${YELLOW}Composer non trovato. Installazione locale...${NC}"
    curl -sS https://getcomposer.org/installer | php
    COMPOSER_CMD="php composer.phar"
    echo -e "${GREEN}✓ Composer installato localmente${NC}"
fi
echo ""

# Installa dipendenze PHP
echo -e "${GREEN}[5/8] Installazione dipendenze PHP...${NC}"
$COMPOSER_CMD install --optimize-autoloader --no-dev --no-interaction
echo -e "${GREEN}✓ Dipendenze PHP installate${NC}"
echo ""

# Configura .env
echo -e "${GREEN}[6/8] Configurazione .env...${NC}"
if [ ! -f .env ]; then
    if [ -f .env.example ]; then
        cp .env.example .env
    else
        touch .env
        echo "APP_NAME=\"FUNTASTING\"" >> .env
        echo "APP_ENV=production" >> .env
        echo "APP_DEBUG=false" >> .env
        echo "APP_URL=http://localhost" >> .env
        echo "DB_CONNECTION=mysql" >> .env
        echo "DB_HOST=127.0.0.1" >> .env
        echo "DB_PORT=3306" >> .env
        echo "DB_DATABASE=funtasting" >> .env
        echo "DB_USERNAME=funtasting_user" >> .env
        echo "DB_PASSWORD=" >> .env
    fi
    php artisan key:generate --force
    echo -e "${GREEN}✓ File .env creato${NC}"
else
    echo -e "${GREEN}✓ File .env già esistente${NC}"
fi

# Chiedi credenziali database
echo ""
echo -e "${YELLOW}📋 CONFIGURAZIONE DATABASE${NC}"
echo -e "${YELLOW}─────────────────────────────────────${NC}"
read -p "Nome Database [funtasting]: " DB_NAME
DB_NAME=${DB_NAME:-funtasting}
read -p "Username Database: " DB_USER
read -sp "Password Database: " DB_PASS
echo ""

# Aggiorna .env
sed -i "s|DB_DATABASE=.*|DB_DATABASE=$DB_NAME|" .env
sed -i "s|DB_USERNAME=.*|DB_USERNAME=$DB_USER|" .env
sed -i "s|DB_PASSWORD=.*|DB_PASSWORD=$DB_PASS|" .env

echo -e "${GREEN}✓ Database configurato${NC}"
echo ""

# Verifica Node.js
echo -e "${GREEN}[7/8] Verifica Node.js...${NC}"
if command -v node &> /dev/null; then
    echo -e "${GREEN}✓ Node.js $(node -v) trovato${NC}"
    echo -e "${GREEN}Installazione dipendenze Node.js...${NC}"
    npm install --silent
    echo -e "${GREEN}Compilazione asset...${NC}"
    npm run build
    echo -e "${GREEN}✓ Asset compilati${NC}"
else
    echo -e "${YELLOW}⚠ Node.js non trovato${NC}"
    echo -e "${YELLOW}Gli asset non verranno compilati.${NC}"
    echo -e "${YELLOW}Installa Node.js o compila gli asset localmente.${NC}"
fi
echo ""

# Setup Laravel
echo -e "${GREEN}[8/8] Setup Laravel...${NC}"
php artisan storage:link || true
php artisan migrate --force || echo -e "${YELLOW}⚠ Migrazioni fallite. Verifica il database.${NC}"
php artisan db:seed --force || echo -e "${YELLOW}⚠ Seeder fallito.${NC}"
php artisan config:cache || true
php artisan route:cache || true
php artisan view:cache || true
echo -e "${GREEN}✓ Setup completato${NC}"
echo ""

# Permessi
echo -e "${GREEN}Impostazione permessi...${NC}"
chmod -R 755 .
chmod -R 775 storage 2>/dev/null || true
chmod -R 775 bootstrap/cache 2>/dev/null || true
echo -e "${GREEN}✓ Permessi impostati${NC}"
echo ""

# Riepilogo
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     ✅ INSTALLAZIONE COMPLETATA!      ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}📋 RIEPILOGO:${NC}"
echo -e "${BLUE}─────────────────────────────────────${NC}"
echo -e "Directory: ${GREEN}$INSTALL_DIR${NC}"
echo -e "Database: ${GREEN}$DB_NAME${NC}"
echo ""
echo -e "${YELLOW}🔐 CREDENZIALI:${NC}"
echo -e "Admin: ${GREEN}admin@funtasting.it${NC} / ${GREEN}password${NC}"
echo ""
echo -e "${YELLOW}🚀 TEST RAPIDO:${NC}"
echo -e "cd $INSTALL_DIR"
echo -e "php artisan serve --host=0.0.0.0 --port=8000"
echo ""
echo -e "${GREEN}✅ Fatto!${NC}"
echo ""

