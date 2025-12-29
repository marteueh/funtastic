#!/bin/bash

# Script per creare database e utente MySQL
# Prova diversi metodi senza richiedere necessariamente root

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   CREAZIONE DATABASE E UTENTE MYSQL   ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Leggi configurazione .env
if [ ! -f .env ]; then
    echo -e "${RED}ERRORE: File .env non trovato!${NC}"
    echo -e "${YELLOW}Esegui prima: bash setup_progetto.sh${NC}"
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
    echo -e "${RED}ERRORE: Configurazione database incompleta!${NC}"
    exit 1
fi

# Chiedi password se non presente
if [ -z "$DB_PASS" ]; then
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

echo -e "${GREEN}Tentativo creazione database e utente...${NC}"
echo ""

# Metodo 1: Prova con sudo mysql
echo -e "${BLUE}[Metodo 1] Tentativo con sudo mysql...${NC}"
if sudo mysql -u root -e "SELECT 1;" &>/dev/null 2>&1; then
    echo -e "${GREEN}✓ Accesso root con sudo disponibile${NC}"
    
    sudo mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS \`$DB_NAME\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
DROP USER IF EXISTS '$DB_USER'@'localhost';
CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
EOF
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Database e utente creati con successo!${NC}"
        echo ""
        
        # Test connessione
        if mysql -u "$DB_USER" -p"$DB_PASS" -e "USE \`$DB_NAME\`; SELECT 1;" &>/dev/null; then
            echo -e "${GREEN}✓ Connessione testata con successo!${NC}"
            echo ""
            echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
            echo -e "${GREEN}║     ✅ DATABASE CONFIGURATO!            ║${NC}"
            echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
            echo ""
            echo -e "${YELLOW}Ora puoi eseguire:${NC}"
            echo -e "${GREEN}php artisan migrate --force${NC}"
            echo -e "${GREEN}php artisan db:seed --force${NC}"
            exit 0
        fi
    fi
else
    echo -e "${YELLOW}✗ Accesso root con sudo non disponibile${NC}"
fi
echo ""

# Metodo 2: Prova con root senza password
echo -e "${BLUE}[Metodo 2] Tentativo con root senza password...${NC}"
if mysql -u root -e "SELECT 1;" &>/dev/null 2>&1; then
    echo -e "${GREEN}✓ Accesso root senza password disponibile${NC}"
    
    mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS \`$DB_NAME\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
DROP USER IF EXISTS '$DB_USER'@'localhost';
CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
EOF
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ Database e utente creati con successo!${NC}"
        echo ""
        
        # Test connessione
        if mysql -u "$DB_USER" -p"$DB_PASS" -e "USE \`$DB_NAME\`; SELECT 1;" &>/dev/null; then
            echo -e "${GREEN}✓ Connessione testata con successo!${NC}"
            echo ""
            echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
            echo -e "${GREEN}║     ✅ DATABASE CONFIGURATO!            ║${NC}"
            echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
            exit 0
        fi
    fi
else
    echo -e "${YELLOW}✗ Accesso root senza password non disponibile${NC}"
fi
echo ""

# Se nessun metodo ha funzionato
echo -e "${RED}✗ Impossibile creare database automaticamente${NC}"
echo ""
echo -e "${YELLOW}════════════════════════════════════════${NC}"
echo -e "${YELLOW}  ISTRUZIONI PER L'AMMINISTRATORE      ${NC}"
echo -e "${YELLOW}════════════════════════════════════════${NC}"
echo ""
echo -e "${BLUE}Chiedi all'amministratore del server di eseguire:${NC}"
echo ""
echo -e "${GREEN}# Connettiti a MySQL come root:${NC}"
echo -e "mysql -u root -p"
echo ""
echo -e "${GREEN}# Oppure con sudo:${NC}"
echo -e "sudo mysql -u root"
echo ""
echo -e "${GREEN}# Poi esegui questi comandi SQL:${NC}"
echo ""
cat <<EOF
CREATE DATABASE IF NOT EXISTS \`$DB_NAME\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
EXIT;
EOF
echo ""
echo -e "${YELLOW}════════════════════════════════════════${NC}"
echo ""
echo -e "${BLUE}OPPURE: Usa SQLite temporaneamente per testare${NC}"
echo ""
read -p "Vuoi configurare SQLite temporaneamente? (s/n) [n]: " USE_SQLITE
USE_SQLITE=${USE_SQLITE:-n}

if [ "$USE_SQLITE" = "s" ] || [ "$USE_SQLITE" = "S" ]; then
    echo ""
    echo -e "${GREEN}Configurazione SQLite...${NC}"
    
    # Cambia .env a SQLite
    sed -i "s|^DB_CONNECTION=.*|DB_CONNECTION=sqlite|" .env
    sed -i "s|^DB_DATABASE=.*|DB_DATABASE=database/database.sqlite|" .env
    
    # Crea database SQLite
    mkdir -p database
    touch database/database.sqlite
    chmod 664 database/database.sqlite
    
    echo -e "${GREEN}✓ SQLite configurato${NC}"
    echo ""
    echo -e "${YELLOW}Ora puoi eseguire:${NC}"
    echo -e "${GREEN}php artisan migrate --force${NC}"
    echo -e "${GREEN}php artisan db:seed --force${NC}"
    echo ""
    echo -e "${YELLOW}⚠ Nota: SQLite è solo per test. Per produzione usa MySQL.${NC}"
fi
echo ""

