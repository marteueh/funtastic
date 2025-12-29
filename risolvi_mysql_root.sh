#!/bin/bash

# Script per risolvere problemi di accesso MySQL root
# Esegui con: bash risolvi_mysql_root.sh

set -e

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   RISOLUZIONE ACCESSO MYSQL ROOT     ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Verifica MySQL in esecuzione
echo -e "${GREEN}[1/5] Verifica MySQL in esecuzione...${NC}"
if systemctl is-active --quiet mysql 2>/dev/null || systemctl is-active --quiet mariadb 2>/dev/null; then
    echo -e "${GREEN}✓ MySQL/MariaDB è in esecuzione${NC}"
    MYSQL_RUNNING=true
elif pgrep -x mysqld > /dev/null || pgrep -x mariadbd > /dev/null; then
    echo -e "${GREEN}✓ MySQL/MariaDB è in esecuzione (processo trovato)${NC}"
    MYSQL_RUNNING=true
else
    echo -e "${RED}✗ MySQL/MariaDB NON è in esecuzione${NC}"
    MYSQL_RUNNING=false
fi
echo ""

# Verifica versione MySQL
echo -e "${GREEN}[2/5] Verifica versione MySQL...${NC}"
if command -v mysql &> /dev/null; then
    MYSQL_VERSION=$(mysql --version 2>/dev/null || echo "non disponibile")
    echo -e "${GREEN}✓ MySQL trovato: $MYSQL_VERSION${NC}"
else
    echo -e "${RED}✗ MySQL client non trovato${NC}"
    exit 1
fi
echo ""

# Test diversi metodi di accesso
echo -e "${GREEN}[3/5] Test accesso MySQL root...${NC}"
echo -e "${YELLOW}Provo diversi metodi di autenticazione...${NC}"
echo ""

# Metodo 1: Senza password
echo -e "${BLUE}Metodo 1: Accesso senza password...${NC}"
if mysql -u root -e "SELECT 1;" &>/dev/null; then
    echo -e "${GREEN}✓ Accesso root senza password funziona!${NC}"
    ROOT_ACCESS="no_password"
    ROOT_PASS=""
elif mysql -u root --password="" -e "SELECT 1;" &>/dev/null; then
    echo -e "${GREEN}✓ Accesso root con password vuota funziona!${NC}"
    ROOT_ACCESS="empty_password"
    ROOT_PASS=""
else
    echo -e "${YELLOW}✗ Accesso senza password fallito${NC}"
    ROOT_ACCESS=""
fi
echo ""

# Se non funziona, chiedi password
if [ -z "$ROOT_ACCESS" ]; then
    echo -e "${YELLOW}Metodo 2: Accesso con password...${NC}"
    read -sp "Inserisci password MySQL root: " ROOT_PASS
    echo ""
    
    if mysql -u root -p"$ROOT_PASS" -e "SELECT 1;" &>/dev/null; then
        echo -e "${GREEN}✓ Accesso root con password funziona!${NC}"
        ROOT_ACCESS="password"
    else
        echo -e "${RED}✗ Accesso root con password fallito${NC}"
        ROOT_ACCESS="failed"
    fi
    echo ""
fi

# Se ancora non funziona, prova sudo
if [ "$ROOT_ACCESS" = "failed" ]; then
    echo -e "${YELLOW}Metodo 3: Accesso con sudo (auth_socket)...${NC}"
    if sudo mysql -u root -e "SELECT 1;" &>/dev/null; then
        echo -e "${GREEN}✓ Accesso root con sudo funziona!${NC}"
        ROOT_ACCESS="sudo"
        USE_SUDO=true
    else
        echo -e "${RED}✗ Accesso root con sudo fallito${NC}"
        ROOT_ACCESS="failed"
    fi
    echo ""
fi

# Se tutto fallisce, mostra opzioni
if [ "$ROOT_ACCESS" = "failed" ] || [ -z "$ROOT_ACCESS" ]; then
    echo -e "${RED}✗ Impossibile accedere a MySQL root${NC}"
    echo ""
    echo -e "${YELLOW}Opzioni disponibili:${NC}"
    echo ""
    echo -e "${BLUE}Opzione A: Reset password root MySQL${NC}"
    echo -e "${YELLOW}1. Ferma MySQL:${NC}"
    echo -e "   ${GREEN}sudo systemctl stop mysql${NC}"
    echo -e "${YELLOW}2. Avvia MySQL in modalità sicura:${NC}"
    echo -e "   ${GREEN}sudo mysqld_safe --skip-grant-tables &${NC}"
    echo -e "${YELLOW}3. Connettiti:${NC}"
    echo -e "   ${GREEN}mysql -u root${NC}"
    echo -e "${YELLOW}4. Esegui:${NC}"
    echo -e "   ${GREEN}ALTER USER 'root'@'localhost' IDENTIFIED BY 'nuova_password';${NC}"
    echo -e "   ${GREEN}FLUSH PRIVILEGES;${NC}"
    echo -e "${YELLOW}5. Riavvia MySQL normalmente${NC}"
    echo ""
    echo -e "${BLUE}Opzione B: Crea utente senza root (se hai accesso admin)${NC}"
    echo -e "${YELLOW}Chiedi all'amministratore di creare l'utente${NC}"
    echo ""
    echo -e "${BLUE}Opzione C: Usa un database esistente${NC}"
    echo -e "${YELLOW}Se hai già un database e utente, configura solo il .env${NC}"
    echo ""
    exit 1
fi

# Se abbiamo accesso, procediamo
echo -e "${GREEN}[4/5] Accesso MySQL root confermato!${NC}"
echo ""

# Leggi configurazione .env
if [ -f .env ]; then
    DB_NAME=$(grep "^DB_DATABASE=" .env | cut -d '=' -f2 | tr -d '"' | tr -d "'" | xargs)
    DB_USER=$(grep "^DB_USERNAME=" .env | cut -d '=' -f2 | tr -d '"' | tr -d "'" | xargs)
    DB_PASS=$(grep "^DB_PASSWORD=" .env | cut -d '=' -f2 | tr -d '"' | tr -d "'" | xargs)
    
    if [ -n "$DB_NAME" ] && [ -n "$DB_USER" ]; then
        echo -e "${GREEN}Configurazione dal .env:${NC}"
        echo -e "  Database: ${BLUE}$DB_NAME${NC}"
        echo -e "  Username: ${BLUE}$DB_USER${NC}"
        echo ""
        
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
        
        # Crea database e utente
        echo -e "${GREEN}[5/5] Creazione database e utente...${NC}"
        
        if [ "$USE_SUDO" = true ]; then
            MYSQL_CMD="sudo mysql"
        elif [ -n "$ROOT_PASS" ]; then
            MYSQL_CMD="mysql -u root -p$ROOT_PASS"
        else
            MYSQL_CMD="mysql -u root"
        fi
        
        # Crea database
        $MYSQL_CMD <<EOF
CREATE DATABASE IF NOT EXISTS \`$DB_NAME\` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
EOF
        echo -e "${GREEN}✓ Database '$DB_NAME' creato${NC}"
        
        # Crea utente
        $MYSQL_CMD <<EOF
DROP USER IF EXISTS '$DB_USER'@'localhost';
CREATE USER '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';
GRANT ALL PRIVILEGES ON \`$DB_NAME\`.* TO '$DB_USER'@'localhost';
FLUSH PRIVILEGES;
EOF
        echo -e "${GREEN}✓ Utente '$DB_USER' creato${NC}"
        echo ""
        
        # Test connessione
        echo -e "${GREEN}Test connessione con nuovo utente...${NC}"
        if mysql -u "$DB_USER" -p"$DB_PASS" -e "USE \`$DB_NAME\`; SELECT 1;" &>/dev/null; then
            echo -e "${GREEN}✓ Connessione con nuovo utente OK!${NC}"
        else
            echo -e "${YELLOW}⚠ Connessione fallita, ma utente creato${NC}"
        fi
        echo ""
        
        # Pulisci cache Laravel
        if [ -f artisan ]; then
            echo -e "${GREEN}Pulizia cache Laravel...${NC}"
            php artisan config:clear
            php artisan cache:clear
            echo -e "${GREEN}✓ Cache pulita${NC}"
            echo ""
            
            # Test Laravel
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
                echo -e "${YELLOW}⚠ Laravel non riesce ancora a connettersi${NC}"
                echo -e "${YELLOW}Esegui: php artisan config:clear && php artisan cache:clear${NC}"
            fi
        fi
    else
        echo -e "${YELLOW}Configurazione database non trovata nel .env${NC}"
        echo -e "${YELLOW}Esegui: bash configura_db.sh${NC}"
    fi
else
    echo -e "${YELLOW}File .env non trovato${NC}"
fi
echo ""

