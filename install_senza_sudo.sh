#!/bin/bash

# Script di installazione FUNTASTING SENZA SUDO
# Esegui con: bash install_senza_sudo.sh

set -e

# Colori
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  INSTALLAZIONE FUNTASTING (NO SUDO)   ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Verifica che non stiamo usando sudo
if [ "$EUID" -eq 0 ]; then
    echo -e "${RED}ERRORE: Non eseguire questo script con sudo!${NC}"
    exit 1
fi

# ============================================
# RACCOLTA INFORMAZIONI
# ============================================

echo -e "${YELLOW}📋 RACCOLTA INFORMAZIONI${NC}"
echo -e "${YELLOW}─────────────────────────────────────${NC}"
echo ""

# 1. Directory di installazione (default: home directory)
read -p "Directory di installazione [$HOME/www/funtasting]: " INSTALL_DIR
INSTALL_DIR=${INSTALL_DIR:-$HOME/www/funtasting}
echo -e "${GREEN}✓ Directory: $INSTALL_DIR${NC}"
echo ""

# 2. Dominio/URL
read -p "Dominio del sito (es. funtasting.com) o IP: " DOMAIN
if [ -z "$DOMAIN" ]; then
    echo -e "${YELLOW}Attenzione: Dominio non specificato. Userò IP del server.${NC}"
    DOMAIN=$(hostname -I | awk '{print $1}')
fi
echo -e "${GREEN}✓ Dominio/IP: $DOMAIN${NC}"
echo ""

# 3. Database - Host
read -p "Database Host [127.0.0.1]: " DB_HOST
DB_HOST=${DB_HOST:-127.0.0.1}
echo -e "${GREEN}✓ DB Host: $DB_HOST${NC}"

# 4. Database - Nome
read -p "Nome Database [funtasting]: " DB_NAME
DB_NAME=${DB_NAME:-funtasting}
echo -e "${GREEN}✓ DB Name: $DB_NAME${NC}"

# 5. Database - Utente
read -p "Database Username: " DB_USER
if [ -z "$DB_USER" ]; then
    echo -e "${RED}ERRORE: Username database richiesto!${NC}"
    exit 1
fi
echo -e "${GREEN}✓ DB User: $DB_USER${NC}"

# 6. Database - Password
read -sp "Database Password: " DB_PASS
echo ""
if [ -z "$DB_PASS" ]; then
    echo -e "${RED}ERRORE: Password database richiesta!${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Password configurata${NC}"
echo ""

# ============================================
# VERIFICA PREREQUISITI
# ============================================

echo -e "${YELLOW}🔍 VERIFICA PREREQUISITI${NC}"
echo -e "${YELLOW}─────────────────────────────────────${NC}"

# PHP 8.2+
echo -e "${GREEN}[1/5] Verifica PHP...${NC}"
if ! command -v php &> /dev/null; then
    echo -e "${RED}ERRORE: PHP non trovato!${NC}"
    exit 1
fi
PHP_VERSION=$(php -v | head -n 1 | cut -d " " -f 2 | cut -d "." -f 1,2)
PHP_MAJOR=$(echo $PHP_VERSION | cut -d "." -f 1)
PHP_MINOR=$(echo $PHP_VERSION | cut -d "." -f 2)
if [ "$PHP_MAJOR" -lt 8 ] || ([ "$PHP_MAJOR" -eq 8 ] && [ "$PHP_MINOR" -lt 2 ]); then
    echo -e "${RED}ERRORE: PHP 8.2+ richiesto. Versione trovata: $PHP_VERSION${NC}"
    exit 1
fi
echo -e "${GREEN}✓ PHP $PHP_VERSION trovato${NC}"

# Composer (locale o globale)
echo -e "${GREEN}[2/5] Verifica Composer...${NC}"
COMPOSER_CMD="composer"
if ! command -v composer &> /dev/null; then
    echo -e "${YELLOW}Composer non trovato globalmente. Installazione locale...${NC}"
    if [ ! -f "$HOME/composer.phar" ]; then
        curl -sS https://getcomposer.org/installer | php -- --install-dir=$HOME
    fi
    COMPOSER_CMD="php $HOME/composer.phar"
    echo -e "${GREEN}✓ Composer installato localmente${NC}"
else
    echo -e "${GREEN}✓ Composer trovato${NC}"
fi

# Node.js
echo -e "${GREEN}[3/5] Verifica Node.js...${NC}"
if ! command -v node &> /dev/null; then
    echo -e "${RED}ERRORE: Node.js non trovato!${NC}"
    echo -e "${YELLOW}Installa Node.js manualmente o chiedi all'amministratore.${NC}"
    echo -e "${YELLOW}Puoi compilare gli asset localmente e caricarli.${NC}"
    read -p "Vuoi continuare senza Node.js? (s/n) [n]: " CONTINUE_NO_NODE
    CONTINUE_NO_NODE=${CONTINUE_NO_NODE:-n}
    if [ "$CONTINUE_NO_NODE" != "s" ]; then
        exit 1
    fi
    NODE_AVAILABLE=false
else
    echo -e "${GREEN}✓ Node.js $(node -v) trovato${NC}"
    NODE_AVAILABLE=true
fi

# MySQL client
echo -e "${GREEN}[4/5] Verifica MySQL client...${NC}"
if ! command -v mysql &> /dev/null; then
    echo -e "${YELLOW}MySQL client non trovato. Assicurati che il database sia già creato.${NC}"
    MYSQL_AVAILABLE=false
else
    echo -e "${GREEN}✓ MySQL client trovato${NC}"
    MYSQL_AVAILABLE=true
fi

# Git
echo -e "${GREEN}[5/5] Verifica Git...${NC}"
if ! command -v git &> /dev/null; then
    echo -e "${RED}ERRORE: Git non trovato!${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Git installato${NC}"

echo ""

# ============================================
# INSTALLAZIONE PROGETTO
# ============================================

echo -e "${YELLOW}📦 INSTALLAZIONE PROGETTO${NC}"
echo -e "${YELLOW}─────────────────────────────────────${NC}"

# Crea directory
echo -e "${GREEN}[1/9] Creazione directory...${NC}"
mkdir -p "$(dirname $INSTALL_DIR)"
if [ -d "$INSTALL_DIR" ]; then
    echo -e "${YELLOW}Directory esistente. Aggiornamento...${NC}"
    cd "$INSTALL_DIR"
    git pull origin main || echo -e "${YELLOW}Git pull fallito, continuo...${NC}"
else
    echo -e "${GREEN}Clonazione repository...${NC}"
    git clone https://github.com/marteueh/funtastic.git "$INSTALL_DIR"
fi
cd "$INSTALL_DIR"
echo -e "${GREEN}✓ Directory pronta${NC}"

# Installa dipendenze Composer
echo -e "${GREEN}[2/9] Installazione dipendenze PHP...${NC}"
$COMPOSER_CMD install --optimize-autoloader --no-dev --no-interaction
echo -e "${GREEN}✓ Dipendenze PHP installate${NC}"

# Configura .env
echo -e "${GREEN}[3/9] Configurazione .env...${NC}"
if [ ! -f .env ]; then
    cp .env.example .env 2>/dev/null || touch .env
    
    # Genera APP_KEY
    php artisan key:generate --force
    
    # Configura .env
    if ! grep -q "APP_NAME" .env; then
        echo "APP_NAME=\"FUNTASTING\"" >> .env
    fi
    sed -i "s|APP_NAME=.*|APP_NAME=\"FUNTASTING\"|" .env 2>/dev/null || true
    
    if ! grep -q "APP_ENV" .env; then
        echo "APP_ENV=production" >> .env
    fi
    sed -i "s|APP_ENV=.*|APP_ENV=production|" .env 2>/dev/null || true
    
    if ! grep -q "APP_DEBUG" .env; then
        echo "APP_DEBUG=false" >> .env
    fi
    sed -i "s|APP_DEBUG=.*|APP_DEBUG=false|" .env 2>/dev/null || true
    
    if ! grep -q "APP_URL" .env; then
        echo "APP_URL=http://$DOMAIN" >> .env
    fi
    sed -i "s|APP_URL=.*|APP_URL=http://$DOMAIN|" .env 2>/dev/null || true
    
    if ! grep -q "DB_CONNECTION" .env; then
        echo "DB_CONNECTION=mysql" >> .env
    fi
    sed -i "s|DB_CONNECTION=.*|DB_CONNECTION=mysql|" .env 2>/dev/null || true
    
    if ! grep -q "DB_HOST" .env; then
        echo "DB_HOST=$DB_HOST" >> .env
    fi
    sed -i "s|DB_HOST=.*|DB_HOST=$DB_HOST|" .env 2>/dev/null || true
    
    if ! grep -q "DB_PORT" .env; then
        echo "DB_PORT=3306" >> .env
    fi
    sed -i "s|DB_PORT=.*|DB_PORT=3306|" .env 2>/dev/null || true
    
    if ! grep -q "DB_DATABASE" .env; then
        echo "DB_DATABASE=$DB_NAME" >> .env
    fi
    sed -i "s|DB_DATABASE=.*|DB_DATABASE=$DB_NAME|" .env 2>/dev/null || true
    
    if ! grep -q "DB_USERNAME" .env; then
        echo "DB_USERNAME=$DB_USER" >> .env
    fi
    sed -i "s|DB_USERNAME=.*|DB_USERNAME=$DB_USER|" .env 2>/dev/null || true
    
    if ! grep -q "DB_PASSWORD" .env; then
        echo "DB_PASSWORD=$DB_PASS" >> .env
    fi
    sed -i "s|DB_PASSWORD=.*|DB_PASSWORD=$DB_PASS|" .env 2>/dev/null || true
    
    if ! grep -q "LOG_LEVEL" .env; then
        echo "LOG_LEVEL=error" >> .env
    fi
    sed -i "s|LOG_LEVEL=.*|LOG_LEVEL=error|" .env 2>/dev/null || true
    
    if ! grep -q "SESSION_DRIVER" .env; then
        echo "SESSION_DRIVER=database" >> .env
    fi
    sed -i "s|SESSION_DRIVER=.*|SESSION_DRIVER=database|" .env 2>/dev/null || true
    
    echo -e "${GREEN}✓ File .env configurato${NC}"
else
    echo -e "${GREEN}✓ File .env già esistente${NC}"
fi

# Test connessione database
echo -e "${GREEN}[4/9] Test connessione database...${NC}"
if php artisan db:show &>/dev/null; then
    echo -e "${GREEN}✓ Connessione database OK${NC}"
else
    echo -e "${YELLOW}⚠ Connessione database fallita. Assicurati che:${NC}"
    echo -e "${YELLOW}  - Il database '$DB_NAME' esista${NC}"
    echo -e "${YELLOW}  - L'utente '$DB_USER' abbia i permessi${NC}"
    echo -e "${YELLOW}  - Le credenziali siano corrette${NC}"
    read -p "Vuoi continuare comunque? (s/n) [n]: " CONTINUE_DB
    CONTINUE_DB=${CONTINUE_DB:-n}
    if [ "$CONTINUE_DB" != "s" ]; then
        exit 1
    fi
fi

# Installa dipendenze npm (se disponibile)
if [ "$NODE_AVAILABLE" = true ]; then
    echo -e "${GREEN}[5/9] Installazione dipendenze Node.js...${NC}"
    npm install --silent
    echo -e "${GREEN}✓ Dipendenze Node.js installate${NC}"
    
    # Compila asset
    echo -e "${GREEN}[6/9] Compilazione asset frontend...${NC}"
    npm run build
    echo -e "${GREEN}✓ Asset compilati${NC}"
else
    echo -e "${YELLOW}[5-6/9] Saltati (Node.js non disponibile)${NC}"
    echo -e "${YELLOW}⚠ Compila gli asset localmente e caricali in public/build/${NC}"
fi

# Esegui migrazioni
echo -e "${GREEN}[7/9] Esecuzione migrazioni...${NC}"
php artisan migrate --force
echo -e "${GREEN}✓ Migrazioni eseguite${NC}"

# Esegui seeder
echo -e "${GREEN}[8/9] Popolamento database...${NC}"
php artisan db:seed --force
echo -e "${GREEN}✓ Database popolato${NC}"

# Crea link storage
echo -e "${GREEN}[9/9] Creazione link storage...${NC}"
php artisan storage:link || echo -e "${YELLOW}Link storage già esistente${NC}"
echo -e "${GREEN}✓ Link storage creato${NC}"

# Ottimizza cache
echo -e "${GREEN}Ottimizzazione cache...${NC}"
php artisan config:cache
php artisan route:cache
php artisan view:cache
echo -e "${GREEN}✓ Cache ottimizzata${NC}"

# Imposta permessi base (solo per l'utente corrente)
echo -e "${GREEN}Impostazione permessi...${NC}"
chmod -R 755 "$INSTALL_DIR"
chmod -R 775 "$INSTALL_DIR/storage" 2>/dev/null || true
chmod -R 775 "$INSTALL_DIR/bootstrap/cache" 2>/dev/null || true
echo -e "${GREEN}✓ Permessi impostati${NC}"

echo ""

# ============================================
# CONFIGURAZIONE WEB SERVER
# ============================================

echo -e "${YELLOW}🌐 CONFIGURAZIONE WEB SERVER${NC}"
echo -e "${YELLOW}─────────────────────────────────────${NC}"
echo ""
echo -e "${BLUE}Configurazione Nginx/Apache (richiede privilegi admin):${NC}"
echo ""
echo -e "${GREEN}Document Root:${NC} $INSTALL_DIR/public"
echo ""
echo -e "${YELLOW}Esempio configurazione Nginx:${NC}"
cat <<EOF
server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;
    root $INSTALL_DIR/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php;

    charset utf-8;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php${PHP_VERSION}-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
EOF
echo ""

# Salva configurazione in un file
NGINX_CONFIG_FILE="$INSTALL_DIR/nginx.conf.example"
cat > "$NGINX_CONFIG_FILE" <<EOF
# Configurazione Nginx per FUNTASTING
# Copia questo file in /etc/nginx/sites-available/funtasting
# e crea un link simbolico in /etc/nginx/sites-enabled/

server {
    listen 80;
    server_name $DOMAIN www.$DOMAIN;
    root $INSTALL_DIR/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php;

    charset utf-8;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php${PHP_VERSION}-fpm.sock;
        fastcgi_param SCRIPT_FILENAME \$realpath_root\$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
EOF

echo -e "${GREEN}✓ Configurazione salvata in: $NGINX_CONFIG_FILE${NC}"
echo ""

# ============================================
# RIEPILOGO
# ============================================

echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     ✅ INSTALLAZIONE COMPLETATA!      ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}📋 RIEPILOGO CONFIGURAZIONE:${NC}"
echo -e "${BLUE}─────────────────────────────────────${NC}"
echo -e "Directory: ${GREEN}$INSTALL_DIR${NC}"
echo -e "Dominio: ${GREEN}$DOMAIN${NC}"
echo -e "Database: ${GREEN}$DB_NAME${NC}"
echo -e "Utente DB: ${GREEN}$DB_USER${NC}"
echo ""
echo -e "${YELLOW}🔐 CREDENZIALI ACCESSO:${NC}"
echo -e "${YELLOW}─────────────────────────────────────${NC}"
echo -e "Admin: ${GREEN}admin@funtasting.it${NC} / ${GREEN}password${NC}"
echo -e "Vendor: ${GREEN}vendor@funtasting.it${NC} / ${GREEN}password${NC}"
echo -e "Reseller: ${GREEN}reseller@funtasting.it${NC} / ${GREEN}password${NC}"
echo -e "Customer: ${GREEN}customer@funtasting.it${NC} / ${GREEN}password${NC}"
echo ""
echo -e "${YELLOW}🌐 PROSSIMI PASSI:${NC}"
echo -e "${YELLOW}─────────────────────────────────────${NC}"
echo -e "1. Chiedi all'amministratore di configurare Nginx usando:"
echo -e "   ${GREEN}$NGINX_CONFIG_FILE${NC}"
echo -e ""
echo -e "2. Oppure usa PHP built-in server per test:"
echo -e "   ${GREEN}cd $INSTALL_DIR && php artisan serve --host=0.0.0.0 --port=8000${NC}"
echo -e ""
if [ "$NODE_AVAILABLE" != true ]; then
    echo -e "${YELLOW}3. ⚠ Compila gli asset localmente:${NC}"
    echo -e "   ${GREEN}npm install && npm run build${NC}"
    echo -e "   Poi carica la cartella ${GREEN}public/build${NC} sul server"
    echo -e ""
fi
echo -e "${GREEN}✅ Installazione completata!${NC}"
echo ""

