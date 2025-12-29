#!/bin/bash

# Script per configurare le credenziali database nel .env
# Esegui con: bash configura_db.sh

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   CONFIGURAZIONE DATABASE .ENV        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Verifica che siamo nella directory del progetto
if [ ! -f "artisan" ]; then
    echo -e "${RED}ERRORE: Esegui questo script nella directory del progetto Laravel!${NC}"
    exit 1
fi

# Verifica file .env
if [ ! -f .env ]; then
    echo -e "${YELLOW}File .env non trovato. Creazione...${NC}"
    if [ -f .env.example ]; then
        cp .env.example .env
        php artisan key:generate --force
    else
        touch .env
        echo "APP_NAME=\"FUNTASTING\"" >> .env
        echo "APP_ENV=production" >> .env
        echo "APP_DEBUG=false" >> .env
        echo "APP_URL=http://localhost" >> .env
        php artisan key:generate --force
    fi
fi

echo -e "${GREEN}Configurazione credenziali database${NC}"
echo -e "${YELLOW}─────────────────────────────────────${NC}"
echo ""

# Chiedi informazioni database
read -p "Nome Database [funtasting]: " DB_NAME
DB_NAME=${DB_NAME:-funtasting}

read -p "Username Database: " DB_USER
if [ -z "$DB_USER" ]; then
    echo -e "${RED}ERRORE: Username database richiesto!${NC}"
    exit 1
fi

read -sp "Password Database: " DB_PASS
echo ""
if [ -z "$DB_PASS" ]; then
    echo -e "${YELLOW}⚠ Password vuota. Continuo comunque...${NC}"
fi

read -p "Database Host [127.0.0.1]: " DB_HOST
DB_HOST=${DB_HOST:-127.0.0.1}

read -p "Database Port [3306]: " DB_PORT
DB_PORT=${DB_PORT:-3306}

echo ""
echo -e "${GREEN}Configurazione:${NC}"
echo -e "  Database: ${BLUE}$DB_NAME${NC}"
echo -e "  Username: ${BLUE}$DB_USER${NC}"
echo -e "  Host: ${BLUE}$DB_HOST${NC}"
echo -e "  Port: ${BLUE}$DB_PORT${NC}"
echo ""

read -p "Confermi? (s/n) [s]: " CONFERMA
CONFERMA=${CONFERMA:-s}

if [ "$CONFERMA" != "s" ] && [ "$CONFERMA" != "S" ]; then
    echo -e "${YELLOW}Annullato${NC}"
    exit 0
fi

echo ""
echo -e "${GREEN}Aggiornamento file .env...${NC}"

# Assicura che DB_CONNECTION sia mysql
if grep -q "^DB_CONNECTION=" .env; then
    sed -i "s|^DB_CONNECTION=.*|DB_CONNECTION=mysql|" .env
else
    # Trova dove inserire (dopo APP_URL)
    if grep -q "^APP_URL=" .env; then
        sed -i "/^APP_URL=/a DB_CONNECTION=mysql" .env
    else
        echo "DB_CONNECTION=mysql" >> .env
    fi
fi

# Aggiorna o aggiungi DB_HOST
if grep -q "^DB_HOST=" .env; then
    sed -i "s|^DB_HOST=.*|DB_HOST=$DB_HOST|" .env
else
    sed -i "/^DB_CONNECTION=/a DB_HOST=$DB_HOST" .env
fi

# Aggiorna o aggiungi DB_PORT
if grep -q "^DB_PORT=" .env; then
    sed -i "s|^DB_PORT=.*|DB_PORT=$DB_PORT|" .env
else
    sed -i "/^DB_HOST=/a DB_PORT=$DB_PORT" .env
fi

# Aggiorna o aggiungi DB_DATABASE
if grep -q "^DB_DATABASE=" .env; then
    sed -i "s|^DB_DATABASE=.*|DB_DATABASE=$DB_NAME|" .env
else
    sed -i "/^DB_PORT=/a DB_DATABASE=$DB_NAME" .env
fi

# Aggiorna o aggiungi DB_USERNAME
if grep -q "^DB_USERNAME=" .env; then
    sed -i "s|^DB_USERNAME=.*|DB_USERNAME=$DB_USER|" .env
else
    sed -i "/^DB_DATABASE=/a DB_USERNAME=$DB_USER" .env
fi

# Aggiorna o aggiungi DB_PASSWORD
if grep -q "^DB_PASSWORD=" .env; then
    sed -i "s|^DB_PASSWORD=.*|DB_PASSWORD=$DB_PASS|" .env
else
    sed -i "/^DB_USERNAME=/a DB_PASSWORD=$DB_PASS" .env
fi

echo -e "${GREEN}✓ File .env aggiornato${NC}"
echo ""

# Verifica configurazione
echo -e "${GREEN}Verifica configurazione...${NC}"
echo ""
echo -e "${BLUE}Configurazione database nel .env:${NC}"
grep "^DB_" .env
echo ""

# Test connessione
echo -e "${GREEN}Test connessione database...${NC}"
if mysql -u "$DB_USER" -p"$DB_PASS" -h "$DB_HOST" -P "$DB_PORT" -e "SELECT 1;" &>/dev/null; then
    echo -e "${GREEN}✓ Connessione MySQL base OK!${NC}"
    
    # Test database specifico
    if mysql -u "$DB_USER" -p"$DB_PASS" -h "$DB_HOST" -P "$DB_PORT" -e "USE \`$DB_NAME\`;" &>/dev/null; then
        echo -e "${GREEN}✓ Database '$DB_NAME' accessibile!${NC}"
    else
        echo -e "${YELLOW}⚠ Database '$DB_NAME' non esiste o accesso negato${NC}"
        echo -e "${YELLOW}Vuoi creare il database? (s/n):${NC}"
        read -p "> " CREA_DB
        if [ "$CREA_DB" = "s" ] || [ "$CREA_DB" = "S" ]; then
            read -p "Username MySQL root: " MYSQL_ROOT_USER
            MYSQL_ROOT_USER=${MYSQL_ROOT_USER:-root}
            read -sp "Password MySQL root: " MYSQL_ROOT_PASS
            echo ""
            
            mysql -u "$MYSQL_ROOT_USER" -p"$MYSQL_ROOT_PASS" <<EOF
CREATE DATABASE IF NOT EXISTS \`$DB_NAME\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
EOF
            echo -e "${GREEN}✓ Database creato${NC}"
        fi
    fi
else
    ERROR=$(mysql -u "$DB_USER" -p"$DB_PASS" -h "$DB_HOST" -P "$DB_PORT" -e "SELECT 1;" 2>&1)
    echo -e "${RED}✗ Connessione fallita${NC}"
    echo -e "${YELLOW}Errore:${NC}"
    echo "$ERROR" | head -3
    echo ""
    echo -e "${YELLOW}Possibili cause:${NC}"
    echo -e "  - L'utente '$DB_USER' non esiste"
    echo -e "  - La password è errata"
    echo -e "  - MySQL non è in esecuzione"
    echo ""
    echo -e "${BLUE}Vuoi creare l'utente MySQL? (s/n):${NC}"
    read -p "> " CREA_USER
    if [ "$CREA_USER" = "s" ] || [ "$CREA_USER" = "S" ]; then
        read -p "Username MySQL root: " MYSQL_ROOT_USER
        MYSQL_ROOT_USER=${MYSQL_ROOT_USER:-root}
        read -sp "Password MySQL root: " MYSQL_ROOT_PASS
        echo ""
        
        # Crea database
        mysql -u "$MYSQL_ROOT_USER" -p"$MYSQL_ROOT_PASS" <<EOF
CREATE DATABASE IF NOT EXISTS \`$DB_NAME\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
EOF
        
        # Crea utente
        mysql -u "$MYSQL_ROOT_USER" -p"$MYSQL_ROOT_PASS" <<EOF
DROP USER IF EXISTS '$DB_USER'@'localhost';
CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
EOF
        
        echo -e "${GREEN}✓ Utente e database creati${NC}"
    fi
fi

echo ""

# Pulisci cache Laravel
echo -e "${GREEN}Pulizia cache Laravel...${NC}"
php artisan config:clear
php artisan cache:clear
echo -e "${GREEN}✓ Cache pulita${NC}"
echo ""

# Test finale con Laravel
echo -e "${GREEN}Test con Laravel...${NC}"
if php artisan db:show &>/dev/null; then
    echo -e "${GREEN}✅ Laravel può connettersi al database!${NC}"
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║     ✅ CONFIGURAZIONE COMPLETATA!     ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Ora puoi eseguire:${NC}"
    echo -e "${GREEN}php artisan migrate --force${NC}"
    echo -e "${GREEN}php artisan db:seed --force${NC}"
else
    echo -e "${YELLOW}⚠ Laravel non riesce ancora a connettersi${NC}"
    echo -e "${YELLOW}Controlla i log:${NC}"
    echo -e "${GREEN}tail -20 storage/logs/laravel.log${NC}"
fi
echo ""

