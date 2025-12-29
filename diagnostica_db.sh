#!/bin/bash

# Script di diagnostica database MySQL
# Esegui con: bash diagnostica_db.sh

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   DIAGNOSTICA DATABASE MYSQL          ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Verifica che siamo nella directory del progetto
if [ ! -f "artisan" ]; then
    echo -e "${RED}ERRORE: Esegui questo script nella directory del progetto Laravel!${NC}"
    exit 1
fi

# 1. Verifica MySQL in esecuzione
echo -e "${GREEN}[1/7] Verifica MySQL in esecuzione...${NC}"
if systemctl is-active --quiet mysql 2>/dev/null || systemctl is-active --quiet mariadb 2>/dev/null; then
    echo -e "${GREEN}✓ MySQL/MariaDB è in esecuzione${NC}"
elif pgrep -x mysqld > /dev/null || pgrep -x mariadbd > /dev/null; then
    echo -e "${GREEN}✓ MySQL/MariaDB è in esecuzione (processo trovato)${NC}"
else
    echo -e "${RED}✗ MySQL/MariaDB NON è in esecuzione${NC}"
    echo -e "${YELLOW}Avvia MySQL con:${NC}"
    echo -e "${YELLOW}sudo systemctl start mysql${NC}"
    echo -e "${YELLOW}oppure${NC}"
    echo -e "${YELLOW}sudo systemctl start mariadb${NC}"
fi
echo ""

# 2. Verifica estensione PHP MySQL
echo -e "${GREEN}[2/7] Verifica estensione PHP MySQL...${NC}"
if php -m | grep -q "pdo_mysql"; then
    echo -e "${GREEN}✓ Estensione pdo_mysql trovata${NC}"
else
    echo -e "${RED}✗ Estensione pdo_mysql NON trovata${NC}"
    echo -e "${YELLOW}Installa con:${NC}"
    echo -e "${YELLOW}sudo apt install php-mysql${NC}"
    echo -e "${YELLOW}oppure${NC}"
    echo -e "${YELLOW}sudo apt install php8.3-mysql${NC}"
fi
echo ""

# 3. Leggi configurazione .env
echo -e "${GREEN}[3/7] Lettura configurazione .env...${NC}"
if [ ! -f .env ]; then
    echo -e "${RED}✗ File .env non trovato!${NC}"
    exit 1
fi

DB_CONNECTION=$(grep "^DB_CONNECTION=" .env | cut -d '=' -f2 | tr -d '"' | tr -d "'" | xargs)
DB_NAME=$(grep "^DB_DATABASE=" .env | cut -d '=' -f2 | tr -d '"' | tr -d "'" | xargs)
DB_USER=$(grep "^DB_USERNAME=" .env | cut -d '=' -f2 | tr -d '"' | tr -d "'" | xargs)
DB_PASS=$(grep "^DB_PASSWORD=" .env | cut -d '=' -f2 | tr -d '"' | tr -d "'" | xargs)
DB_HOST=$(grep "^DB_HOST=" .env | cut -d '=' -f2 | tr -d '"' | tr -d "'" | xargs)
DB_PORT=$(grep "^DB_PORT=" .env | cut -d '=' -f2 | tr -d '"' | tr -d "'" | xargs)

echo -e "DB_CONNECTION: ${BLUE}${DB_CONNECTION:-non configurato}${NC}"
echo -e "DB_HOST: ${BLUE}${DB_HOST:-127.0.0.1}${NC}"
echo -e "DB_PORT: ${BLUE}${DB_PORT:-3306}${NC}"
echo -e "DB_DATABASE: ${BLUE}${DB_NAME:-non configurato}${NC}"
echo -e "DB_USERNAME: ${BLUE}${DB_USER:-non configurato}${NC}"
echo -e "DB_PASSWORD: ${BLUE}${DB_PASS:+***configurata***}${DB_PASS:-non configurata}${NC}"
echo ""

if [ -z "$DB_NAME" ] || [ -z "$DB_USER" ]; then
    echo -e "${RED}✗ Configurazione database incompleta!${NC}"
    echo -e "${YELLOW}Configura il file .env con le credenziali corrette${NC}"
    exit 1
fi

# 4. Test connessione MySQL base
echo -e "${GREEN}[4/7] Test connessione MySQL (senza database)...${NC}"
if mysql -u "$DB_USER" -p"$DB_PASS" -h "${DB_HOST:-127.0.0.1}" -e "SELECT 1;" 2>&1 | grep -q "ERROR"; then
    ERROR_MSG=$(mysql -u "$DB_USER" -p"$DB_PASS" -h "${DB_HOST:-127.0.0.1}" -e "SELECT 1;" 2>&1)
    echo -e "${RED}✗ Connessione fallita${NC}"
    echo -e "${YELLOW}Errore: $ERROR_MSG${NC}"
    
    if echo "$ERROR_MSG" | grep -q "Access denied"; then
        echo ""
        echo -e "${YELLOW}Possibili soluzioni:${NC}"
        echo -e "  1. L'utente '$DB_USER' non esiste"
        echo -e "  2. La password è errata"
        echo -e "  3. L'utente non ha permessi per connettersi da '${DB_HOST:-127.0.0.1}'"
        echo ""
        echo -e "${BLUE}Vuoi creare un nuovo utente MySQL? (s/n):${NC}"
        read -p "> " CREA_UTENTE
        if [ "$CREA_UTENTE" = "s" ] || [ "$CREA_UTENTE" = "S" ]; then
            echo ""
            read -p "Username MySQL root (o admin): " MYSQL_ROOT_USER
            MYSQL_ROOT_USER=${MYSQL_ROOT_USER:-root}
            read -sp "Password MySQL root: " MYSQL_ROOT_PASS
            echo ""
            echo ""
            
            read -p "Nome nuovo utente MySQL [$DB_USER]: " NEW_DB_USER
            NEW_DB_USER=${NEW_DB_USER:-$DB_USER}
            read -sp "Password nuovo utente MySQL: " NEW_DB_PASS
            echo ""
            echo ""
            
            # Crea database
            echo -e "${GREEN}Creazione database '$DB_NAME'...${NC}"
            mysql -u "$MYSQL_ROOT_USER" -p"$MYSQL_ROOT_PASS" <<EOF 2>/dev/null || true
CREATE DATABASE IF NOT EXISTS \`$DB_NAME\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
EOF
            
            # Crea utente
            echo -e "${GREEN}Creazione utente '$NEW_DB_USER'...${NC}"
            mysql -u "$MYSQL_ROOT_USER" -p"$MYSQL_ROOT_PASS" <<EOF 2>/dev/null || true
DROP USER IF EXISTS '$NEW_DB_USER'@'localhost';
CREATE USER '$NEW_DB_USER'@'localhost' IDENTIFIED BY '$NEW_DB_PASS';
GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$NEW_DB_USER'@'localhost';
FLUSH PRIVILEGES;
EOF
            
            # Aggiorna .env
            sed -i "s|DB_USERNAME=.*|DB_USERNAME=$NEW_DB_USER|" .env
            sed -i "s|DB_PASSWORD=.*|DB_PASSWORD=$NEW_DB_PASS|" .env
            
            DB_USER=$NEW_DB_USER
            DB_PASS=$NEW_DB_PASS
            
            echo -e "${GREEN}✓ Utente creato e .env aggiornato${NC}"
        fi
    fi
else
    echo -e "${GREEN}✓ Connessione MySQL base OK!${NC}"
fi
echo ""

# 5. Verifica database esiste
echo -e "${GREEN}[5/7] Verifica database '$DB_NAME' esiste...${NC}"
if mysql -u "$DB_USER" -p"$DB_PASS" -h "${DB_HOST:-127.0.0.1}" -e "USE \`$DB_NAME\`;" 2>&1 | grep -q "ERROR"; then
    ERROR_MSG=$(mysql -u "$DB_USER" -p"$DB_PASS" -h "${DB_HOST:-127.0.0.1}" -e "USE \`$DB_NAME\`;" 2>&1)
    echo -e "${RED}✗ Database '$DB_NAME' non esiste o accesso negato${NC}"
    echo -e "${YELLOW}Errore: $ERROR_MSG${NC}"
    echo ""
    echo -e "${BLUE}Vuoi creare il database? (s/n):${NC}"
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
else
    echo -e "${GREEN}✓ Database '$DB_NAME' esiste e accessibile${NC}"
fi
echo ""

# 6. Test connessione completa
echo -e "${GREEN}[6/7] Test connessione completa...${NC}"
if mysql -u "$DB_USER" -p"$DB_PASS" -h "${DB_HOST:-127.0.0.1}" "$DB_NAME" -e "SELECT 1;" &>/dev/null; then
    echo -e "${GREEN}✓ Connessione completa OK!${NC}"
else
    echo -e "${RED}✗ Connessione completa fallita${NC}"
    echo -e "${YELLOW}Prova manualmente:${NC}"
    echo -e "${GREEN}mysql -u $DB_USER -p -h ${DB_HOST:-127.0.0.1} $DB_NAME${NC}"
fi
echo ""

# 7. Test con Laravel
echo -e "${GREEN}[7/7] Test con Laravel...${NC}"
php artisan config:clear
php artisan cache:clear

if php artisan db:show &>/dev/null; then
    echo -e "${GREEN}✓ Laravel può connettersi al database!${NC}"
    echo ""
    echo -e "${GREEN}✅ TUTTO OK!${NC}"
    echo ""
    echo -e "${YELLOW}Ora puoi eseguire:${NC}"
    echo -e "${GREEN}php artisan migrate --force${NC}"
    echo -e "${GREEN}php artisan db:seed --force${NC}"
else
    ERROR=$(php artisan db:show 2>&1)
    echo -e "${RED}✗ Laravel non riesce a connettersi${NC}"
    echo -e "${YELLOW}Errore:${NC}"
    echo "$ERROR" | head -5
    echo ""
    echo -e "${YELLOW}Controlla i log:${NC}"
    echo -e "${GREEN}tail -20 storage/logs/laravel.log${NC}"
fi
echo ""

