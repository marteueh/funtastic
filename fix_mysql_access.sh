#!/bin/bash

# Script per risolvere problemi di accesso MySQL
# Esegui con: bash fix_mysql_access.sh

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${YELLOW}🔧 Risoluzione accesso MySQL...${NC}"
echo ""

# Verifica che siamo nella directory del progetto
if [ ! -f "artisan" ]; then
    echo -e "${RED}ERRORE: Esegui questo script nella directory del progetto Laravel!${NC}"
    exit 1
fi

# Leggi configurazione attuale
echo -e "${GREEN}[1/5] Lettura configurazione .env...${NC}"
if [ ! -f .env ]; then
    echo -e "${RED}ERRORE: File .env non trovato!${NC}"
    exit 1
fi

DB_NAME=$(grep "^DB_DATABASE=" .env | cut -d '=' -f2 | tr -d '"' | tr -d "'" | xargs)
DB_USER=$(grep "^DB_USERNAME=" .env | cut -d '=' -f2 | tr -d '"' | tr -d "'" | xargs)
DB_PASS=$(grep "^DB_PASSWORD=" .env | cut -d '=' -f2 | tr -d '"' | tr -d "'" | xargs)
DB_HOST=$(grep "^DB_HOST=" .env | cut -d '=' -f2 | tr -d '"' | tr -d "'" | xargs)

echo -e "Database: ${BLUE}$DB_NAME${NC}"
echo -e "Utente: ${BLUE}$DB_USER${NC}"
echo -e "Host: ${BLUE}$DB_HOST${NC}"
echo ""

# Test connessione
echo -e "${GREEN}[2/5] Test connessione MySQL...${NC}"
if mysql -u "$DB_USER" -p"$DB_PASS" -h "$DB_HOST" -e "SELECT 1;" &>/dev/null; then
    echo -e "${GREEN}✓ Connessione MySQL OK!${NC}"
    CONNECTION_OK=true
else
    echo -e "${RED}✗ Connessione MySQL fallita${NC}"
    CONNECTION_OK=false
fi
echo ""

# Se la connessione fallisce, chiedi nuove credenziali
if [ "$CONNECTION_OK" = false ]; then
    echo -e "${YELLOW}⚠ La connessione con le credenziali attuali non funziona.${NC}"
    echo -e "${YELLOW}Possibili cause:${NC}"
    echo -e "  1. L'utente MySQL non esiste"
    echo -e "  2. La password è errata"
    echo -e "  3. L'utente non ha i permessi necessari"
    echo ""
    echo -e "${BLUE}Opzioni:${NC}"
    echo -e "  A) Creare un nuovo utente MySQL (consigliato)"
    echo -e "  B) Usare credenziali esistenti"
    echo ""
    read -p "Scegli (A/B): " SCELTA
    
    if [ "$SCELTA" = "A" ] || [ "$SCELTA" = "a" ]; then
        echo ""
        echo -e "${GREEN}[3/5] Creazione nuovo utente MySQL...${NC}"
        echo -e "${YELLOW}Ti servirà la password MySQL root o di un utente con privilegi.${NC}"
        echo ""
        read -p "Username MySQL root (o admin): " MYSQL_ROOT_USER
        MYSQL_ROOT_USER=${MYSQL_ROOT_USER:-root}
        read -sp "Password MySQL root: " MYSQL_ROOT_PASS
        echo ""
        echo ""
        
        # Chiedi nuovo utente
        read -p "Nome nuovo utente MySQL [funtasting_user]: " NEW_DB_USER
        NEW_DB_USER=${NEW_DB_USER:-funtasting_user}
        read -sp "Password nuovo utente MySQL: " NEW_DB_PASS
        echo ""
        echo ""
        
        # Crea database se non esiste
        echo -e "${GREEN}Creazione database...${NC}"
        mysql -u "$MYSQL_ROOT_USER" -p"$MYSQL_ROOT_PASS" <<EOF 2>/dev/null || true
CREATE DATABASE IF NOT EXISTS \`$DB_NAME\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
EOF
        
        # Crea utente
        echo -e "${GREEN}Creazione utente...${NC}"
        mysql -u "$MYSQL_ROOT_USER" -p"$MYSQL_ROOT_PASS" <<EOF 2>/dev/null || true
CREATE USER IF NOT EXISTS '$NEW_DB_USER'@'localhost' IDENTIFIED BY '$NEW_DB_PASS';
GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$NEW_DB_USER'@'localhost';
FLUSH PRIVILEGES;
EOF
        
        # Aggiorna .env
        sed -i "s|DB_USERNAME=.*|DB_USERNAME=$NEW_DB_USER|" .env
        sed -i "s|DB_PASSWORD=.*|DB_PASSWORD=$NEW_DB_PASS|" .env
        
        DB_USER=$NEW_DB_USER
        DB_PASS=$NEW_DB_PASS
        
        echo -e "${GREEN}✓ Utente MySQL creato${NC}"
    else
        echo ""
        echo -e "${GREEN}[3/5] Configurazione credenziali esistenti...${NC}"
        read -p "Username MySQL: " NEW_DB_USER
        read -sp "Password MySQL: " NEW_DB_PASS
        echo ""
        
        # Aggiorna .env
        sed -i "s|DB_USERNAME=.*|DB_USERNAME=$NEW_DB_USER|" .env
        sed -i "s|DB_PASSWORD=.*|DB_PASSWORD=$NEW_DB_PASS|" .env
        
        DB_USER=$NEW_DB_USER
        DB_PASS=$NEW_DB_PASS
    fi
    echo ""
else
    echo -e "${GREEN}[3/5] Connessione OK, salto creazione utente${NC}"
    echo ""
fi

# Test connessione finale
echo -e "${GREEN}[4/5] Test connessione finale...${NC}"
if mysql -u "$DB_USER" -p"$DB_PASS" -h "$DB_HOST" -e "USE \`$DB_NAME\`; SELECT 1;" &>/dev/null; then
    echo -e "${GREEN}✓ Connessione al database OK!${NC}"
else
    echo -e "${RED}✗ Connessione ancora fallita${NC}"
    echo -e "${YELLOW}Verifica manualmente:${NC}"
    echo -e "  mysql -u $DB_USER -p -h $DB_HOST"
    exit 1
fi
echo ""

# Pulisci cache Laravel
echo -e "${GREEN}[5/5] Pulizia cache Laravel...${NC}"
php artisan config:clear
php artisan cache:clear
php artisan config:cache
echo -e "${GREEN}✓ Cache pulita${NC}"
echo ""

# Test con Laravel
echo -e "${GREEN}Test con Laravel...${NC}"
if php artisan db:show &>/dev/null; then
    echo -e "${GREEN}✓ Laravel può connettersi al database!${NC}"
    echo ""
    echo -e "${GREEN}✅ Configurazione completata!${NC}"
    echo ""
    echo -e "${YELLOW}Ora puoi eseguire:${NC}"
    echo -e "${GREEN}php artisan migrate --force${NC}"
    echo -e "${GREEN}php artisan db:seed --force${NC}"
else
    echo -e "${RED}⚠ Laravel non riesce ancora a connettersi${NC}"
    echo -e "${YELLOW}Controlla i log:${NC}"
    echo -e "${GREEN}tail -f storage/logs/laravel.log${NC}"
fi
echo ""

