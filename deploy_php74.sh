#!/bin/bash

# 🚀 Script Deploy FUNTASTING per PHP 7.4
# Esegui questo script sul server

set -e  # Esce in caso di errore

echo "🚀 Deploy FUNTASTING (PHP 7.4 Compatible)"
echo "=========================================="

# Colori per output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Directory di installazione
INSTALL_DIR="/home/users/fantasting/www"
PROJECT_DIR="$INSTALL_DIR/funtasting"

echo -e "${YELLOW}[1/12]${NC} Verifica directory..."
cd "$INSTALL_DIR" || exit 1
echo "✅ Directory: $INSTALL_DIR"

echo -e "${YELLOW}[2/12]${NC} Rimozione vecchia installazione..."
if [ -d "$PROJECT_DIR" ]; then
    rm -rf "$PROJECT_DIR"
    echo "✅ Vecchia installazione rimossa"
else
    echo "ℹ️  Nessuna installazione precedente trovata"
fi

echo -e "${YELLOW}[3/12]${NC} Clone repository..."
if command -v git &> /dev/null; then
    git clone -b php7.4-compatible https://github.com/marteueh/funtastic.git funtasting
    echo "✅ Repository clonato"
else
    echo -e "${RED}❌ Git non trovato. Installazione con wget...${NC}"
    wget https://github.com/marteueh/funtastic/archive/refs/heads/php7.4-compatible.zip -O funtasting.zip
    unzip -q funtasting.zip
    mv funtastic-php7.4-compatible funtasting
    rm funtasting.zip
    echo "✅ Repository scaricato"
fi

cd "$PROJECT_DIR" || exit 1

echo -e "${YELLOW}[4/12]${NC} Verifica PHP..."
PHP_VERSION=$(php -r "echo PHP_VERSION;" 2>/dev/null || echo "0")
echo "PHP versione: $PHP_VERSION"
if [ "$(printf '%s\n' "7.4" "$PHP_VERSION" | sort -V | head -n1)" != "7.4" ]; then
    echo -e "${RED}⚠️  Attenzione: PHP 7.4+ richiesto. Versione attuale: $PHP_VERSION${NC}"
fi

echo -e "${YELLOW}[5/12]${NC} Installazione Composer..."
if [ ! -f "bin/composer" ]; then
    if command -v curl &> /dev/null; then
        curl -sS https://getcomposer.org/installer | php
    else
        php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
        php composer-setup.php
        php -r "unlink('composer-setup.php');"
    fi
    mkdir -p bin
    mv composer.phar bin/composer
    chmod +x bin/composer
    echo "✅ Composer installato"
else
    echo "ℹ️  Composer già presente"
fi

echo -e "${YELLOW}[6/12]${NC} Installazione dipendenze PHP..."
./bin/composer install --optimize-autoloader --no-dev --no-interaction --quiet
echo "✅ Dipendenze installate"

echo -e "${YELLOW}[7/12]${NC} Configurazione .env..."
if [ ! -f ".env" ]; then
    cp .env.example .env
    echo "✅ File .env creato"
    
    # Genera APP_KEY
    php artisan key:generate --quiet
    echo "✅ APP_KEY generato"
else
    echo "ℹ️  File .env già esistente"
fi

echo -e "${YELLOW}[8/12]${NC} Creazione database SQLite..."
mkdir -p database
touch database/database.sqlite
chmod 664 database/database.sqlite
chmod 775 database
echo "✅ Database SQLite creato"

echo -e "${YELLOW}[9/12]${NC} Esecuzione migrazioni..."
php artisan migrate --force --quiet
echo "✅ Migrazioni completate"

echo -e "${YELLOW}[10/12]${NC} Creazione link storage..."
php artisan storage:link --quiet
echo "✅ Link storage creato"

echo -e "${YELLOW}[11/12]${NC} Ottimizzazione cache..."
php artisan config:cache --quiet
php artisan route:cache --quiet
php artisan view:cache --quiet
echo "✅ Cache ottimizzata"

echo -e "${YELLOW}[12/12]${NC} Impostazione permessi..."
chmod -R 775 storage bootstrap/cache 2>/dev/null || echo "⚠️  Impossibile impostare permessi (potrebbe richiedere sudo)"
chmod 664 database/database.sqlite 2>/dev/null || true
echo "✅ Permessi impostati"

echo ""
echo -e "${GREEN}=========================================="
echo "✅ INSTALLAZIONE COMPLETATA!"
echo "==========================================${NC}"
echo ""
echo "📁 Directory: $PROJECT_DIR"
echo ""
echo "🚀 Per avviare il server:"
echo "   cd $PROJECT_DIR"
echo "   php artisan serve --host=0.0.0.0 --port=8000"
echo ""
echo "🌐 URL: http://217.114.212.10:8000"
echo ""
echo "📝 Ricorda di configurare .env con:"
echo "   - APP_URL=http://217.114.212.10:8000"
echo "   - DB_DATABASE=$PROJECT_DIR/database/database.sqlite"
echo ""
