#!/bin/bash

# Script per creare database e utente MariaDB/MySQL
# Ottimizzato per MariaDB

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   CREAZIONE DATABASE MARIADB/MYSQL    ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Verifica MariaDB/MySQL
echo -e "${GREEN}[1/6] Verifica MariaDB/MySQL...${NC}"
if systemctl is-active --quiet mariadb 2>/dev/null; then
    echo -e "${GREEN}✓ MariaDB è in esecuzione${NC}"
    DB_SERVICE="mariadb"
elif systemctl is-active --quiet mysql 2>/dev/null; then
    echo -e "${GREEN}✓ MySQL è in esecuzione${NC}"
    DB_SERVICE="mysql"
elif pgrep -x mariadbd > /dev/null || pgrep -x mysqld > /dev/null; then
    echo -e "${GREEN}✓ MariaDB/MySQL è in esecuzione (processo trovato)${NC}"
    DB_SERVICE="mariadb"
else
    echo -e "${RED}✗ MariaDB/MySQL NON è in esecuzione${NC}"
    echo -e "${YELLOW}Avvia con: sudo systemctl start mariadb${NC}"
    exit 1
fi
echo ""

# Verifica versione
if command -v mysql &> /dev/null; then
    DB_VERSION=$(mysql --version 2>/dev/null || echo "non disponibile")
    echo -e "${GREEN}✓ Versione: $DB_VERSION${NC}"
fi
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

echo -e "${GREEN}[2/6] Configurazione dal .env:${NC}"
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

echo -e "${GREEN}[3/6] Tentativo creazione database e utente...${NC}"
echo ""

# Metodo 1: Prova con sudo mysql (MariaDB spesso usa questo)
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
        CREATED=true
    else
        echo -e "${YELLOW}⚠ Errore nella creazione${NC}"
        CREATED=false
    fi
else
    echo -e "${YELLOW}✗ Accesso root con sudo non disponibile${NC}"
    CREATED=false
fi
echo ""

# Metodo 2: Prova con root senza password
if [ "$CREATED" != "true" ]; then
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
            CREATED=true
        fi
    else
        echo -e "${YELLOW}✗ Accesso root senza password non disponibile${NC}"
    fi
    echo ""
fi

# Metodo 3: Prova con root e password
if [ "$CREATED" != "true" ]; then
    echo -e "${BLUE}[Metodo 3] Tentativo con root e password...${NC}"
    read -sp "Password MySQL root (lascia vuoto per saltare): " ROOT_PASS
    echo ""
    
    if [ -n "$ROOT_PASS" ]; then
        if mysql -u root -p"$ROOT_PASS" -e "SELECT 1;" &>/dev/null 2>&1; then
            echo -e "${GREEN}✓ Accesso root con password disponibile${NC}"
            
            mysql -u root -p"$ROOT_PASS" <<EOF
CREATE DATABASE IF NOT EXISTS \`$DB_NAME\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
DROP USER IF EXISTS '$DB_USER'@'localhost';
CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
EOF
            
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}✓ Database e utente creati con successo!${NC}"
                CREATED=true
            fi
        else
            echo -e "${YELLOW}✗ Password root errata${NC}"
        fi
    fi
    echo ""
fi

# Test connessione
if [ "$CREATED" = "true" ]; then
    echo -e "${GREEN}[4/6] Test connessione...${NC}"
    sleep 1  # Aspetta che i privilegi siano propagati
    
    if mysql -u "$DB_USER" -p"$DB_PASS" -e "USE \`$DB_NAME\`; SELECT 1;" &>/dev/null 2>&1; then
        echo -e "${GREEN}✓ Connessione testata con successo!${NC}"
    else
        echo -e "${YELLOW}⚠ Connessione fallita, ma database creato${NC}"
        echo -e "${YELLOW}Prova a riconnetterti tra qualche secondo${NC}"
    fi
    echo ""
    
    # Pulisci cache Laravel
    echo -e "${GREEN}[5/6] Pulizia cache Laravel...${NC}"
    if [ -f artisan ]; then
        php artisan config:clear
        php artisan cache:clear
        echo -e "${GREEN}✓ Cache pulita${NC}"
    fi
    echo ""
    
    # Test finale con Laravel
    echo -e "${GREEN}[6/6] Test con Laravel...${NC}"
    if [ -f artisan ]; then
        if php artisan db:show &>/dev/null 2>&1; then
            echo -e "${GREEN}✅ Laravel può connettersi al database!${NC}"
            echo ""
            echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
            echo -e "${GREEN}║     ✅ DATABASE CONFIGURATO!            ║${NC}"
            echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
            echo ""
            echo -e "${YELLOW}Ora puoi eseguire:${NC}"
            echo -e "${GREEN}php artisan migrate --force${NC}"
            echo -e "${GREEN}php artisan db:seed --force${NC}"
        else
            echo -e "${YELLOW}⚠ Laravel non riesce ancora a connettersi${NC}"
            echo -e "${YELLOW}Esegui: php artisan config:clear && php artisan cache:clear${NC}"
        fi
    fi
else
    echo -e "${RED}✗ Impossibile creare database automaticamente${NC}"
    echo ""
    echo -e "${YELLOW}════════════════════════════════════════${NC}"
    echo -e "${YELLOW}  ISTRUZIONI PER L'AMMINISTRATORE      ${NC}"
    echo -e "${YELLOW}════════════════════════════════════════${NC}"
    echo ""
    echo -e "${BLUE}Chiedi all'amministratore del server di eseguire:${NC}"
    echo ""
    echo -e "${GREEN}# Connettiti a MariaDB come root:${NC}"
    echo -e "sudo mysql -u root"
    echo ""
    echo -e "${GREEN}# Oppure:${NC}"
    echo -e "mysql -u root -p"
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
fi
echo ""

