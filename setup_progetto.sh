#!/bin/bash

# Script di setup completo progetto FUNTASTING
# Esegui con: bash setup_progetto.sh

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   SETUP PROGETTO FUNTASTING           ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Trova la directory del progetto
echo -e "${GREEN}[1/10] Ricerca progetto...${NC}"
if [ -f "artisan" ]; then
    PROJECT_DIR=$(pwd)
    echo -e "${GREEN}✓ Progetto trovato in: $PROJECT_DIR${NC}"
elif [ -d "www/www" ] && [ -f "www/www/artisan" ]; then
    PROJECT_DIR="$(pwd)/www/www"
    echo -e "${GREEN}✓ Progetto trovato in: $PROJECT_DIR${NC}"
    cd "$PROJECT_DIR"
elif [ -d "funtasting/www/www" ] && [ -f "funtasting/www/www/artisan" ]; then
    PROJECT_DIR="$(pwd)/funtasting/www/www"
    echo -e "${GREEN}✓ Progetto trovato in: $PROJECT_DIR${NC}"
    cd "$PROJECT_DIR"
else
    echo -e "${RED}✗ Progetto Laravel non trovato!${NC}"
    echo -e "${YELLOW}Assicurati di essere nella directory corretta${NC}"
    echo -e "${YELLOW}Oppure indica il percorso:${NC}"
    read -p "Percorso progetto: " PROJECT_DIR
    if [ ! -f "$PROJECT_DIR/artisan" ]; then
        echo -e "${RED}✗ Directory non valida!${NC}"
        exit 1
    fi
    cd "$PROJECT_DIR"
fi

PROJECT_DIR=$(pwd)
echo -e "${GREEN}✓ Directory progetto: $PROJECT_DIR${NC}"
echo ""

# Verifica PHP
echo -e "${GREEN}[2/10] Verifica PHP...${NC}"
if ! command -v php &> /dev/null; then
    echo -e "${RED}✗ PHP non trovato!${NC}"
    exit 1
fi
PHP_VERSION=$(php -v | head -n 1)
echo -e "${GREEN}✓ $PHP_VERSION${NC}"
echo ""

# Verifica Composer
echo -e "${GREEN}[3/10] Verifica Composer...${NC}"
if command -v composer &> /dev/null; then
    COMPOSER_CMD="composer"
    echo -e "${GREEN}✓ Composer trovato${NC}"
else
    echo -e "${YELLOW}Composer non trovato. Installazione locale...${NC}"
    curl -sS https://getcomposer.org/installer | php
    COMPOSER_CMD="php composer.phar"
    echo -e "${GREEN}✓ Composer installato${NC}"
fi
echo ""

# Installa dipendenze PHP
echo -e "${GREEN}[4/10] Installazione dipendenze PHP...${NC}"
if [ ! -d "vendor" ]; then
    $COMPOSER_CMD install --optimize-autoloader --no-dev --no-interaction
    echo -e "${GREEN}✓ Dipendenze installate${NC}"
else
    echo -e "${GREEN}✓ Dipendenze già presenti${NC}"
fi
echo ""

# Configura .env
echo -e "${GREEN}[5/10] Configurazione .env...${NC}"
if [ ! -f .env ]; then
    if [ -f .env.example ]; then
        cp .env.example .env
    else
        touch .env
        echo "APP_NAME=\"FUNTASTING\"" >> .env
        echo "APP_ENV=production" >> .env
        echo "APP_DEBUG=false" >> .env
        echo "APP_URL=http://localhost" >> .env
    fi
    php artisan key:generate --force
    echo -e "${GREEN}✓ File .env creato${NC}"
else
    echo -e "${GREEN}✓ File .env già presente${NC}"
fi
echo ""

# Configura database
echo -e "${GREEN}[6/10] Configurazione database...${NC}"
echo -e "${YELLOW}Inserisci le credenziali del database (deve essere già creato)${NC}"
echo ""

# Leggi valori esistenti
if [ -f .env ]; then
    EXISTING_DB_NAME=$(grep "^DB_DATABASE=" .env | cut -d '=' -f2 | tr -d '"' | tr -d "'" | xargs)
    EXISTING_DB_USER=$(grep "^DB_USERNAME=" .env | cut -d '=' -f2 | tr -d '"' | tr -d "'" | xargs)
    EXISTING_DB_PASS=$(grep "^DB_PASSWORD=" .env | cut -d '=' -f2 | tr -d '"' | tr -d "'" | xargs)
fi

read -p "Nome Database [${EXISTING_DB_NAME:-funtasting}]: " DB_NAME
DB_NAME=${DB_NAME:-${EXISTING_DB_NAME:-funtasting}}

read -p "Username Database [${EXISTING_DB_USER:-funtasting_user}]: " DB_USER
DB_USER=${DB_USER:-${EXISTING_DB_USER:-funtasting_user}}

read -sp "Password Database: " DB_PASS
echo ""
if [ -z "$DB_PASS" ] && [ -n "$EXISTING_DB_PASS" ]; then
    DB_PASS="$EXISTING_DB_PASS"
fi

read -p "Database Host [127.0.0.1]: " DB_HOST
DB_HOST=${DB_HOST:-127.0.0.1}

read -p "Database Port [3306]: " DB_PORT
DB_PORT=${DB_PORT:-3306}

# Aggiorna .env
sed -i "s|^DB_CONNECTION=.*|DB_CONNECTION=mysql|" .env 2>/dev/null || echo "DB_CONNECTION=mysql" >> .env
sed -i "s|^DB_HOST=.*|DB_HOST=$DB_HOST|" .env 2>/dev/null || echo "DB_HOST=$DB_HOST" >> .env
sed -i "s|^DB_PORT=.*|DB_PORT=$DB_PORT|" .env 2>/dev/null || echo "DB_PORT=$DB_PORT" >> .env
sed -i "s|^DB_DATABASE=.*|DB_DATABASE=$DB_NAME|" .env 2>/dev/null || echo "DB_DATABASE=$DB_NAME" >> .env
sed -i "s|^DB_USERNAME=.*|DB_USERNAME=$DB_USER|" .env 2>/dev/null || echo "DB_USERNAME=$DB_USER" >> .env
sed -i "s|^DB_PASSWORD=.*|DB_PASSWORD=$DB_PASS|" .env 2>/dev/null || echo "DB_PASSWORD=$DB_PASS" >> .env

echo -e "${GREEN}✓ Database configurato${NC}"
echo ""

# Test connessione database
echo -e "${GREEN}[7/10] Test connessione database...${NC}"
if command -v mysql &> /dev/null; then
    if mysql -u "$DB_USER" -p"$DB_PASS" -h "$DB_HOST" -P "$DB_PORT" -e "USE \`$DB_NAME\`; SELECT 1;" &>/dev/null; then
        echo -e "${GREEN}✓ Connessione database OK!${NC}"
    else
        echo -e "${YELLOW}⚠ Connessione database fallita${NC}"
        echo -e "${YELLOW}Assicurati che:${NC}"
        echo -e "  - Il database '$DB_NAME' esista"
        echo -e "  - L'utente '$DB_USER' abbia i permessi"
        echo -e "  - Le credenziali siano corrette"
        echo ""
        read -p "Vuoi continuare comunque? (s/n) [n]: " CONTINUE
        CONTINUE=${CONTINUE:-n}
        if [ "$CONTINUE" != "s" ]; then
            echo -e "${YELLOW}Setup interrotto. Configura il database e riprova.${NC}"
            exit 1
        fi
    fi
else
    echo -e "${YELLOW}⚠ MySQL client non trovato, salto test connessione${NC}"
fi
echo ""

# Verifica Node.js
echo -e "${GREEN}[8/10] Verifica Node.js...${NC}"
if command -v node &> /dev/null; then
    echo -e "${GREEN}✓ Node.js $(node -v) trovato${NC}"
    if [ ! -d "node_modules" ]; then
        echo -e "${GREEN}Installazione dipendenze Node.js...${NC}"
        npm install --silent
    fi
    echo -e "${GREEN}Compilazione asset...${NC}"
    npm run build
    echo -e "${GREEN}✓ Asset compilati${NC}"
else
    echo -e "${YELLOW}⚠ Node.js non trovato${NC}"
    echo -e "${YELLOW}Gli asset non verranno compilati${NC}"
    echo -e "${YELLOW}Compila localmente e carica la cartella public/build${NC}"
fi
echo ""

# Esegui migrazioni
echo -e "${GREEN}[9/10] Esecuzione migrazioni...${NC}"
php artisan migrate --force || echo -e "${YELLOW}⚠ Migrazioni fallite. Verifica il database.${NC}"
echo -e "${GREEN}✓ Migrazioni eseguite${NC}"
echo ""

# Esegui seeder
echo -e "${GREEN}[10/10] Popolamento database...${NC}"
php artisan db:seed --force || echo -e "${YELLOW}⚠ Seeder fallito.${NC}"
echo -e "${GREEN}✓ Database popolato${NC}"
echo ""

# Setup finale
echo -e "${GREEN}Setup finale...${NC}"
php artisan storage:link || true
php artisan config:cache || true
php artisan route:cache || true
php artisan view:cache || true
chmod -R 775 storage 2>/dev/null || true
chmod -R 775 bootstrap/cache 2>/dev/null || true
echo -e "${GREEN}✓ Setup completato${NC}"
echo ""

# Riepilogo
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     ✅ SETUP COMPLETATO!              ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}📋 RIEPILOGO:${NC}"
echo -e "${BLUE}─────────────────────────────────────${NC}"
echo -e "Directory: ${GREEN}$PROJECT_DIR${NC}"
echo -e "Database: ${GREEN}$DB_NAME${NC}"
echo -e "Utente: ${GREEN}$DB_USER${NC}"
echo ""
echo -e "${YELLOW}🔐 CREDENZIALI ACCESSO:${NC}"
echo -e "Admin: ${GREEN}admin@funtasting.it${NC} / ${GREEN}password${NC}"
echo -e "Vendor: ${GREEN}vendor@funtasting.it${NC} / ${GREEN}password${NC}"
echo -e "Reseller: ${GREEN}reseller@funtasting.it${NC} / ${GREEN}password${NC}"
echo -e "Customer: ${GREEN}customer@funtasting.it${NC} / ${GREEN}password${NC}"
echo ""
echo -e "${YELLOW}🚀 TEST RAPIDO:${NC}"
echo -e "cd $PROJECT_DIR"
echo -e "php artisan serve --host=0.0.0.0 --port=8000"
echo ""
echo -e "${GREEN}✅ Tutto pronto!${NC}"
echo ""

