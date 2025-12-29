#!/bin/bash

# Script per testare la connessione database
# Esegui con: bash test_connessione_db.sh

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   TEST CONNESSIONE DATABASE           ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Verifica che siamo nella directory del progetto
if [ ! -f "artisan" ]; then
    echo -e "${RED}ERRORE: Esegui questo script nella directory del progetto Laravel!${NC}"
    exit 1
fi

# Leggi configurazione .env
if [ ! -f .env ]; then
    echo -e "${RED}ERRORE: File .env non trovato!${NC}"
    exit 1
fi

DB_NAME=$(grep "^DB_DATABASE=" .env | cut -d '=' -f2 | tr -d '"' | tr -d "'" | xargs)
DB_USER=$(grep "^DB_USERNAME=" .env | cut -d '=' -f2 | tr -d '"' | tr -d "'" | xargs)
DB_PASS=$(grep "^DB_PASSWORD=" .env | cut -d '=' -f2 | tr -d '"' | tr -d "'" | xargs)
DB_HOST=$(grep "^DB_HOST=" .env | cut -d '=' -f2 | tr -d '"' | tr -d "'" | xargs)
DB_HOST=${DB_HOST:-127.0.0.1}

echo -e "${GREEN}Configurazione letta da .env:${NC}"
echo -e "  Database: ${BLUE}$DB_NAME${NC}"
echo -e "  Username: ${BLUE}$DB_USER${NC}"
echo -e "  Host: ${BLUE}$DB_HOST${NC}"
echo ""

if [ -z "$DB_NAME" ] || [ -z "$DB_USER" ]; then
    echo -e "${RED}ERRORE: Configurazione database incompleta nel .env!${NC}"
    exit 1
fi

# Test 1: Verifica MySQL in esecuzione
echo -e "${GREEN}[1/4] Verifica MySQL in esecuzione...${NC}"
if systemctl is-active --quiet mysql 2>/dev/null || systemctl is-active --quiet mariadb 2>/dev/null; then
    echo -e "${GREEN}✓ MySQL/MariaDB è in esecuzione${NC}"
elif pgrep -x mysqld > /dev/null || pgrep -x mariadbd > /dev/null; then
    echo -e "${GREEN}✓ MySQL/MariaDB è in esecuzione (processo trovato)${NC}"
else
    echo -e "${RED}✗ MySQL/MariaDB NON è in esecuzione${NC}"
    echo -e "${YELLOW}Avvia MySQL con: sudo systemctl start mysql${NC}"
    exit 1
fi
echo ""

# Test 2: Verifica estensione PHP
echo -e "${GREEN}[2/4] Verifica estensione PHP MySQL...${NC}"
if php -m | grep -q "pdo_mysql"; then
    echo -e "${GREEN}✓ Estensione pdo_mysql trovata${NC}"
else
    echo -e "${RED}✗ Estensione pdo_mysql NON trovata${NC}"
    echo -e "${YELLOW}Installa con: sudo apt install php-mysql${NC}"
    exit 1
fi
echo ""

# Test 3: Test connessione MySQL (con timeout)
echo -e "${GREEN}[3/4] Test connessione MySQL...${NC}"
echo -e "${YELLOW}Questo potrebbe richiedere alcuni secondi...${NC}"

# Crea un file temporaneo per il test
TMP_FILE=$(mktemp)
TIMEOUT=10

# Test con timeout
timeout $TIMEOUT mysql -u "$DB_USER" -p"$DB_PASS" -h "$DB_HOST" -e "SELECT 1;" > "$TMP_FILE" 2>&1
MYSQL_EXIT=$?

if [ $MYSQL_EXIT -eq 0 ]; then
    echo -e "${GREEN}✓ Connessione MySQL base OK!${NC}"
    
    # Test database specifico
    timeout $TIMEOUT mysql -u "$DB_USER" -p"$DB_PASS" -h "$DB_HOST" -e "USE \`$DB_NAME\`; SELECT 1;" > "$TMP_FILE" 2>&1
    DB_EXIT=$?
    
    if [ $DB_EXIT -eq 0 ]; then
        echo -e "${GREEN}✓ Database '$DB_NAME' accessibile!${NC}"
    else
        ERROR_MSG=$(cat "$TMP_FILE")
        echo -e "${RED}✗ Database '$DB_NAME' non accessibile${NC}"
        echo -e "${YELLOW}Errore:${NC}"
        echo "$ERROR_MSG" | head -3
        echo ""
        echo -e "${YELLOW}Il database potrebbe non esistere o l'utente non ha i permessi${NC}"
    fi
elif [ $MYSQL_EXIT -eq 124 ]; then
    echo -e "${RED}✗ Timeout: La connessione ha impiegato troppo tempo${NC}"
    echo -e "${YELLOW}Possibili cause:${NC}"
    echo -e "  - MySQL non risponde"
    echo -e "  - Firewall blocca la connessione"
    echo -e "  - Host errato"
else
    ERROR_MSG=$(cat "$TMP_FILE")
    echo -e "${RED}✗ Connessione fallita${NC}"
    echo -e "${YELLOW}Errore:${NC}"
    echo "$ERROR_MSG" | head -5
    
    if echo "$ERROR_MSG" | grep -q "Access denied"; then
        echo ""
        echo -e "${YELLOW}Possibili cause:${NC}"
        echo -e "  - Username errato: '$DB_USER'"
        echo -e "  - Password errata"
        echo -e "  - L'utente non esiste"
    fi
fi

rm -f "$TMP_FILE"
echo ""

# Test 4: Test con Laravel
echo -e "${GREEN}[4/4] Test con Laravel...${NC}"
php artisan config:clear > /dev/null 2>&1
php artisan cache:clear > /dev/null 2>&1

LARAVEL_OUTPUT=$(php artisan db:show 2>&1)
LARAVEL_EXIT=$?

if [ $LARAVEL_EXIT -eq 0 ]; then
    echo -e "${GREEN}✓ Laravel può connettersi al database!${NC}"
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║        ✅ TUTTO OK!                   ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Ora puoi eseguire:${NC}"
    echo -e "${GREEN}php artisan migrate --force${NC}"
    echo -e "${GREEN}php artisan db:seed --force${NC}"
else
    echo -e "${RED}✗ Laravel non riesce a connettersi${NC}"
    echo -e "${YELLOW}Errore Laravel:${NC}"
    echo "$LARAVEL_OUTPUT" | head -10
    echo ""
    echo -e "${YELLOW}Controlla i log:${NC}"
    echo -e "${GREEN}tail -20 storage/logs/laravel.log${NC}"
fi
echo ""

