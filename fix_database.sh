#!/bin/bash

# Script per correggere la configurazione database
# Esegui con: bash fix_database.sh

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${YELLOW}🔧 Correzione configurazione database...${NC}"
echo ""

# Verifica che siamo nella directory del progetto
if [ ! -f "artisan" ]; then
    echo -e "${RED}ERRORE: Esegui questo script nella directory del progetto Laravel!${NC}"
    exit 1
fi

# Verifica estensioni PHP
echo -e "${GREEN}[1/4] Verifica estensioni PHP...${NC}"
if php -m | grep -q "pdo_mysql"; then
    echo -e "${GREEN}✓ Estensione pdo_mysql trovata${NC}"
else
    echo -e "${RED}ERRORE: Estensione pdo_mysql non trovata!${NC}"
    echo -e "${YELLOW}Installa l'estensione PHP MySQL:${NC}"
    echo -e "${YELLOW}sudo apt install php-mysql${NC}"
    echo -e "${YELLOW}oppure${NC}"
    echo -e "${YELLOW}sudo apt install php8.3-mysql${NC}"
    exit 1
fi
echo ""

# Verifica file .env
echo -e "${GREEN}[2/4] Verifica file .env...${NC}"
if [ ! -f .env ]; then
    echo -e "${YELLOW}File .env non trovato. Creazione...${NC}"
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
fi
echo -e "${GREEN}✓ File .env presente${NC}"
echo ""

# Correggi DB_CONNECTION
echo -e "${GREEN}[3/4] Correzione DB_CONNECTION...${NC}"
if grep -q "DB_CONNECTION=sqlite" .env; then
    sed -i "s/DB_CONNECTION=sqlite/DB_CONNECTION=mysql/" .env
    echo -e "${GREEN}✓ DB_CONNECTION cambiato da sqlite a mysql${NC}"
elif ! grep -q "DB_CONNECTION=" .env; then
    # Aggiungi DB_CONNECTION se non esiste
    if ! grep -q "^DB_CONNECTION" .env; then
        sed -i '/^APP_URL/a DB_CONNECTION=mysql' .env
        echo -e "${GREEN}✓ DB_CONNECTION=mysql aggiunto${NC}"
    fi
else
    echo -e "${GREEN}✓ DB_CONNECTION già configurato${NC}"
fi
echo ""

# Chiedi credenziali database se non presenti
echo -e "${GREEN}[4/4] Configurazione credenziali database...${NC}"
if ! grep -q "DB_DATABASE=" .env || grep -q "DB_DATABASE=$" .env || grep -q "DB_DATABASE=laravel" .env; then
    echo -e "${YELLOW}Configurazione database necessaria:${NC}"
    read -p "Nome Database: " DB_NAME
    read -p "Username Database: " DB_USER
    read -sp "Password Database: " DB_PASS
    echo ""
    
    # Aggiorna .env
    if grep -q "DB_DATABASE=" .env; then
        sed -i "s|DB_DATABASE=.*|DB_DATABASE=$DB_NAME|" .env
    else
        echo "DB_DATABASE=$DB_NAME" >> .env
    fi
    
    if grep -q "DB_USERNAME=" .env; then
        sed -i "s|DB_USERNAME=.*|DB_USERNAME=$DB_USER|" .env
    else
        echo "DB_USERNAME=$DB_USER" >> .env
    fi
    
    if grep -q "DB_PASSWORD=" .env; then
        sed -i "s|DB_PASSWORD=.*|DB_PASSWORD=$DB_PASS|" .env
    else
        echo "DB_PASSWORD=$DB_PASS" >> .env
    fi
    
    if ! grep -q "DB_HOST=" .env; then
        echo "DB_HOST=127.0.0.1" >> .env
    fi
    
    if ! grep -q "DB_PORT=" .env; then
        echo "DB_PORT=3306" >> .env
    fi
    
    echo -e "${GREEN}✓ Credenziali database configurate${NC}"
else
    echo -e "${GREEN}✓ Credenziali database già presenti${NC}"
fi
echo ""

# Pulisci cache
echo -e "${GREEN}Pulizia cache...${NC}"
php artisan config:clear
php artisan cache:clear
echo -e "${GREEN}✓ Cache pulita${NC}"
echo ""

# Test connessione
echo -e "${GREEN}Test connessione database...${NC}"
if php artisan db:show &>/dev/null; then
    echo -e "${GREEN}✓ Connessione database OK!${NC}"
    echo ""
    echo -e "${GREEN}✅ Configurazione completata!${NC}"
    echo ""
    echo -e "${YELLOW}Ora puoi eseguire:${NC}"
    echo -e "${GREEN}php artisan migrate --force${NC}"
    echo -e "${GREEN}php artisan db:seed --force${NC}"
else
    echo -e "${RED}⚠ Connessione database fallita${NC}"
    echo -e "${YELLOW}Verifica:${NC}"
    echo -e "  - Il database esiste"
    echo -e "  - L'utente ha i permessi"
    echo -e "  - Le credenziali nel .env sono corrette"
    echo ""
    echo -e "${YELLOW}Contenuto .env (solo DB_*):${NC}"
    grep "^DB_" .env
fi
echo ""

