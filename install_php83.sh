#!/bin/bash

# Script di installazione automatica FUNTASTING per PHP 8.3
# Esegui con: bash install_php83.sh

set -e

echo "🚀 Installazione FUNTASTING (PHP 8.3)"
echo "======================================"

# Colori
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Directory di installazione
INSTALL_DIR="/home/users/fantasting/www/funtasting"
REPO_URL="https://github.com/marteueh/funtastic.git"

# 1. Verifica PHP 8.3
echo -e "${GREEN}[1/12] Verifica PHP 8.3...${NC}"
PHP_VERSION=$(php -v | head -n 1 | cut -d " " -f 2 | cut -d "." -f 1,2)
if [[ "$PHP_VERSION" != "8.3" ]]; then
    echo -e "${RED}ERRORE: PHP 8.3 richiesto. Versione trovata: $PHP_VERSION${NC}"
    exit 1
fi
echo -e "${GREEN}✓ PHP 8.3 trovato${NC}"

# 2. Verifica Composer
echo -e "${GREEN}[2/12] Verifica Composer...${NC}"
if ! command -v composer &> /dev/null; then
    echo -e "${YELLOW}Composer non trovato. Installazione...${NC}"
    curl -sS https://getcomposer.org/installer | php
    sudo mv composer.phar /usr/local/bin/composer
    sudo chmod +x /usr/local/bin/composer
fi
echo -e "${GREEN}✓ Composer installato${NC}"

# 3. Verifica Node.js
echo -e "${GREEN}[3/12] Verifica Node.js...${NC}"
if ! command -v node &> /dev/null; then
    echo -e "${YELLOW}Node.js non trovato. Installazione...${NC}"
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt install -y nodejs
fi
echo -e "${GREEN}✓ Node.js installato${NC}"

# 4. Prepara directory
echo -e "${GREEN}[4/12] Preparazione directory...${NC}"
mkdir -p "$(dirname $INSTALL_DIR)"
if [ -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}Directory esistente. Aggiornamento repository...${NC}"
    cd "$INSTALL_DIR"
    git pull origin main || echo -e "${YELLOW}Git pull fallito, continuo...${NC}"
else
    echo -e "${GREEN}Clonazione repository...${NC}"
    git clone "$REPO_URL" "$INSTALL_DIR"
fi
cd "$INSTALL_DIR"
echo -e "${GREEN}✓ Directory pronta${NC}"

# 5. Installa dipendenze Composer
echo -e "${GREEN}[5/12] Installazione dipendenze PHP...${NC}"
composer install --optimize-autoloader --no-dev --no-interaction
echo -e "${GREEN}✓ Dipendenze PHP installate${NC}"

# 6. Configura .env
echo -e "${GREEN}[6/12] Configurazione .env...${NC}"
if [ ! -f .env ]; then
    cp .env.example .env
    echo -e "${YELLOW}File .env creato. Configuralo manualmente!${NC}"
    echo -e "${YELLOW}IMPORTANTE: Modifica .env con le tue credenziali database${NC}"
else
    echo -e "${GREEN}File .env già esistente${NC}"
fi

# 7. Genera APP_KEY
echo -e "${GREEN}[7/12] Generazione APP_KEY...${NC}"
if ! grep -q "APP_KEY=base64:" .env 2>/dev/null; then
    php artisan key:generate --force
    echo -e "${GREEN}✓ APP_KEY generato${NC}"
else
    echo -e "${GREEN}✓ APP_KEY già presente${NC}"
fi

# 8. Installa dipendenze npm
echo -e "${GREEN}[8/12] Installazione dipendenze Node.js...${NC}"
npm install
echo -e "${GREEN}✓ Dipendenze Node.js installate${NC}"

# 9. Compila asset
echo -e "${GREEN}[9/12] Compilazione asset frontend...${NC}"
npm run build
echo -e "${GREEN}✓ Asset compilati${NC}"

# 10. Imposta permessi
echo -e "${GREEN}[10/12] Impostazione permessi...${NC}"
if [ -w "$INSTALL_DIR" ]; then
    chmod -R 755 "$INSTALL_DIR"
    chmod -R 775 "$INSTALL_DIR/storage" 2>/dev/null || true
    chmod -R 775 "$INSTALL_DIR/bootstrap/cache" 2>/dev/null || true
    echo -e "${GREEN}✓ Permessi impostati${NC}"
else
    echo -e "${YELLOW}Impossibile impostare permessi (richiede sudo)${NC}"
    echo -e "${YELLOW}Esegui manualmente:${NC}"
    echo -e "${YELLOW}sudo chown -R www-data:www-data $INSTALL_DIR${NC}"
    echo -e "${YELLOW}sudo chmod -R 755 $INSTALL_DIR${NC}"
    echo -e "${YELLOW}sudo chmod -R 775 $INSTALL_DIR/storage${NC}"
    echo -e "${YELLOW}sudo chmod -R 775 $INSTALL_DIR/bootstrap/cache${NC}"
fi

# 11. Crea link storage
echo -e "${GREEN}[11/12] Creazione link simbolico storage...${NC}"
php artisan storage:link || echo -e "${YELLOW}Link storage già esistente${NC}"
echo -e "${GREEN}✓ Link storage creato${NC}"

# 12. Ottimizza cache
echo -e "${GREEN}[12/12] Ottimizzazione cache...${NC}"
php artisan config:cache || true
php artisan route:cache || true
php artisan view:cache || true
echo -e "${GREEN}✓ Cache ottimizzata${NC}"

echo ""
echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✅ Installazione completata!${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo -e "${YELLOW}PROSSIMI PASSI:${NC}"
echo -e "1. Configura il file .env con le credenziali del database"
echo -e "2. Crea il database MySQL:"
echo -e "   mysql -u root -p"
echo -e "   CREATE DATABASE nome_database;"
echo -e "3. Esegui le migrazioni:"
echo -e "   cd $INSTALL_DIR"
echo -e "   php artisan migrate --force"
echo -e "   php artisan db:seed"
echo -e "4. Configura Nginx (vedi DEPLOY_PHP83.md)"
echo ""
echo -e "${GREEN}Directory installazione: $INSTALL_DIR${NC}"

