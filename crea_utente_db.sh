#!/bin/bash

# Script per creare utente e database MySQL
# Esegui con: bash crea_utente_db.sh

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   CREAZIONE UTENTE E DATABASE MYSQL   ║${NC}"
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

echo -e "${GREEN}Configurazione dal .env:${NC}"
echo -e "  Database: ${BLUE}$DB_NAME${NC}"
echo -e "  Username: ${BLUE}$DB_USER${NC}"
echo ""

if [ -z "$DB_NAME" ] || [ -z "$DB_USER" ]; then
    echo -e "${RED}ERRORE: Configurazione database incompleta nel .env!${NC}"
    echo -e "${YELLOW}Esegui prima: bash configura_db.sh${NC}"
    exit 1
fi

# Chiedi credenziali MySQL root
echo -e "${YELLOW}Per creare l'utente e il database, servono le credenziali MySQL root${NC}"
echo ""
read -p "Username MySQL root [root]: " MYSQL_ROOT_USER
MYSQL_ROOT_USER=${MYSQL_ROOT_USER:-root}
read -sp "Password MySQL root: " MYSQL_ROOT_PASS
echo ""
echo ""

# Chiedi password per il nuovo utente se non presente
if [ -z "$DB_PASS" ]; then
    echo -e "${YELLOW}Password non configurata nel .env${NC}"
    read -sp "Password per l'utente '$DB_USER': " DB_PASS
    echo ""
    echo ""
    
    # Aggiorna .env
    if grep -q "^DB_PASSWORD=" .env; then
        sed -i "s|^DB_PASSWORD=.*|DB_PASSWORD=$DB_PASS|" .env
    else
        sed -i "/^DB_USERNAME=/a DB_PASSWORD=$DB_PASS" .env
    fi
fi

echo -e "${GREEN}Creazione database e utente...${NC}"
echo ""

# Test connessione root
echo -e "${GREEN}[1/4] Test connessione MySQL root...${NC}"
if mysql -u "$MYSQL_ROOT_USER" -p"$MYSQL_ROOT_PASS" -e "SELECT 1;" &>/dev/null; then
    echo -e "${GREEN}✓ Connessione root OK${NC}"
else
    echo -e "${RED}✗ Connessione root fallita${NC}"
    echo -e "${YELLOW}Verifica username e password MySQL root${NC}"
    exit 1
fi
echo ""

# Crea database
echo -e "${GREEN}[2/4] Creazione database '$DB_NAME'...${NC}"
mysql -u "$MYSQL_ROOT_USER" -p"$MYSQL_ROOT_PASS" <<EOF
CREATE DATABASE IF NOT EXISTS \`$DB_NAME\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
EOF

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Database '$DB_NAME' creato${NC}"
else
    echo -e "${RED}✗ Errore nella creazione del database${NC}"
    exit 1
fi
echo ""

# Rimuovi utente esistente se presente (per ricrearlo)
echo -e "${GREEN}[3/4] Creazione utente '$DB_USER'...${NC}"
mysql -u "$MYSQL_ROOT_USER" -p"$MYSQL_ROOT_PASS" <<EOF
DROP USER IF EXISTS '$DB_USER'@'localhost';
CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';
EOF

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Utente '$DB_USER' creato${NC}"
else
    echo -e "${RED}✗ Errore nella creazione dell'utente${NC}"
    exit 1
fi
echo ""

# Assegna permessi
echo -e "${GREEN}[4/4] Assegnazione permessi...${NC}"
mysql -u "$MYSQL_ROOT_USER" -p"$MYSQL_ROOT_PASS" <<EOF
GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
EOF

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Permessi assegnati${NC}"
else
    echo -e "${RED}✗ Errore nell'assegnazione dei permessi${NC}"
    exit 1
fi
echo ""

# Test connessione con nuovo utente
echo -e "${GREEN}Test connessione con nuovo utente...${NC}"
if mysql -u "$DB_USER" -p"$DB_PASS" -e "USE \`$DB_NAME\`; SELECT 1;" &>/dev/null; then
    echo -e "${GREEN}✓ Connessione con nuovo utente OK!${NC}"
else
    echo -e "${YELLOW}⚠ Connessione con nuovo utente fallita, ma database e utente creati${NC}"
    echo -e "${YELLOW}Prova a riconnetterti o riavvia MySQL${NC}"
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
    echo -e "${GREEN}║     ✅ TUTTO CONFIGURATO!             ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${YELLOW}Ora puoi eseguire:${NC}"
    echo -e "${GREEN}php artisan migrate --force${NC}"
    echo -e "${GREEN}php artisan db:seed --force${NC}"
else
    LARAVEL_ERROR=$(php artisan db:show 2>&1)
    echo -e "${YELLOW}⚠ Laravel non riesce ancora a connettersi${NC}"
    echo -e "${YELLOW}Errore:${NC}"
    echo "$LARAVEL_ERROR" | head -5
    echo ""
    echo -e "${YELLOW}Prova a:${NC}"
    echo -e "  1. Riavviare MySQL: sudo systemctl restart mysql"
    echo -e "  2. Verificare il file .env"
    echo -e "  3. Eseguire: php artisan config:clear"
fi
echo ""

