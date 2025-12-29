#!/bin/bash

# Script per verificare se il database esiste
# Esegui con: bash verifica_database.sh

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   VERIFICA DATABASE MARIADB/MYSQL     ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

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

echo -e "${GREEN}Configurazione dal .env:${NC}"
echo -e "  Database: ${BLUE}$DB_NAME${NC}"
echo -e "  Username: ${BLUE}$DB_USER${NC}"
echo -e "  Host: ${BLUE}$DB_HOST${NC}"
echo ""

# Metodo 1: Lista tutti i database (con root)
echo -e "${GREEN}[1/3] Lista tutti i database...${NC}"
echo ""

if sudo mysql -u root -e "SHOW DATABASES;" 2>/dev/null; then
    echo ""
    echo -e "${GREEN}✓ Accesso con sudo mysql root riuscito${NC}"
elif mysql -u root -e "SHOW DATABASES;" 2>/dev/null; then
    echo ""
    echo -e "${GREEN}✓ Accesso con mysql root riuscito${NC}"
else
    echo -e "${YELLOW}⚠ Impossibile accedere come root${NC}"
    echo -e "${YELLOW}Provo con l'utente configurato...${NC}"
    echo ""
fi
echo ""

# Metodo 2: Verifica database specifico
echo -e "${GREEN}[2/3] Verifica database '$DB_NAME'...${NC}"

# Prova con diversi metodi
DB_EXISTS=false

# Con sudo root
if sudo mysql -u root -e "USE \`$DB_NAME\`;" &>/dev/null 2>&1; then
    echo -e "${GREEN}✓ Database '$DB_NAME' ESISTE (verificato con sudo root)${NC}"
    DB_EXISTS=true
# Con root senza password
elif mysql -u root -e "USE \`$DB_NAME\`;" &>/dev/null 2>&1; then
    echo -e "${GREEN}✓ Database '$DB_NAME' ESISTE (verificato con root)${NC}"
    DB_EXISTS=true
# Con utente configurato
elif [ -n "$DB_USER" ] && [ -n "$DB_PASS" ]; then
    if mysql -u "$DB_USER" -p"$DB_PASS" -h "$DB_HOST" -e "USE \`$DB_NAME\`;" &>/dev/null 2>&1; then
        echo -e "${GREEN}✓ Database '$DB_NAME' ESISTE (verificato con utente configurato)${NC}"
        DB_EXISTS=true
    else
        ERROR=$(mysql -u "$DB_USER" -p"$DB_PASS" -h "$DB_HOST" -e "USE \`$DB_NAME\`;" 2>&1)
        if echo "$ERROR" | grep -q "Unknown database"; then
            echo -e "${RED}✗ Database '$DB_NAME' NON ESISTE${NC}"
        elif echo "$ERROR" | grep -q "Access denied"; then
            echo -e "${YELLOW}⚠ Accesso negato - verifica credenziali${NC}"
        else
            echo -e "${RED}✗ Database '$DB_NAME' NON ESISTE o accesso negato${NC}"
        fi
    fi
else
    echo -e "${YELLOW}⚠ Credenziali non configurate nel .env${NC}"
fi
echo ""

# Metodo 3: Verifica utente
if [ -n "$DB_USER" ]; then
    echo -e "${GREEN}[3/3] Verifica utente '$DB_USER'...${NC}"
    
    # Prova con root
    if sudo mysql -u root -e "SELECT User, Host FROM mysql.user WHERE User='$DB_USER';" 2>/dev/null | grep -q "$DB_USER"; then
        echo -e "${GREEN}✓ Utente '$DB_USER' ESISTE${NC}"
        
        # Mostra permessi
        echo ""
        echo -e "${BLUE}Permessi utente:${NC}"
        sudo mysql -u root -e "SHOW GRANTS FOR '$DB_USER'@'localhost';" 2>/dev/null || true
    elif mysql -u root -e "SELECT User, Host FROM mysql.user WHERE User='$DB_USER';" 2>/dev/null | grep -q "$DB_USER"; then
        echo -e "${GREEN}✓ Utente '$DB_USER' ESISTE${NC}"
        
        # Mostra permessi
        echo ""
        echo -e "${BLUE}Permessi utente:${NC}"
        mysql -u root -e "SHOW GRANTS FOR '$DB_USER'@'localhost';" 2>/dev/null || true
    else
        echo -e "${RED}✗ Utente '$DB_USER' NON ESISTE${NC}"
    fi
fi
echo ""

# Riepilogo
echo -e "${BLUE}════════════════════════════════════════${NC}"
if [ "$DB_EXISTS" = true ]; then
    echo -e "${GREEN}✅ DATABASE ESISTE${NC}"
    echo ""
    echo -e "${YELLOW}Ora puoi eseguire:${NC}"
    echo -e "${GREEN}php artisan migrate --force${NC}"
    echo -e "${GREEN}php artisan db:seed --force${NC}"
else
    echo -e "${RED}❌ DATABASE NON ESISTE${NC}"
    echo ""
    echo -e "${YELLOW}Per crearlo, esegui:${NC}"
    echo -e "${GREEN}bash crea_database_mariadb.sh${NC}"
    echo ""
    echo -e "${YELLOW}Oppure manualmente:${NC}"
    echo -e "${GREEN}sudo mysql -u root${NC}"
    echo -e "${GREEN}CREATE DATABASE $DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;${NC}"
fi
echo -e "${BLUE}════════════════════════════════════════${NC}"
echo ""

