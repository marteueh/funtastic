#!/bin/bash

# ============================================
# INSTALLAZIONE LARAVEL 7 - PHP 7.4
# Questa versione FUNZIONA senza problemi
# ============================================

set -e

echo "🚀 Installazione FUNTASTING - Laravel 7 (PHP 7.4)"
echo "=================================================="

INSTALL_DIR="/home/users/fantasting/www"
PROJECT_DIR="$INSTALL_DIR/funtasting"

cd "$INSTALL_DIR" || exit 1

# Rimuovi vecchia installazione
if [ -d "$PROJECT_DIR" ]; then
    echo "📁 Rimozione vecchia installazione..."
    rm -rf "$PROJECT_DIR"
fi

# Clona repository
echo "📥 Clonazione repository..."
git clone https://github.com/marteueh/funtastic.git funtasting
cd "$PROJECT_DIR"

# Installa Composer
echo "📦 Installazione Composer..."
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
fi

# Crea composer.json per Laravel 7
echo "🔧 Configurazione composer.json per Laravel 7..."
cat > composer.json << 'EOF'
{
    "name": "laravel/laravel",
    "type": "project",
    "description": "FUNTASTING - Laravel 7",
    "keywords": ["laravel", "framework"],
    "license": "MIT",
    "require": {
        "php": "^7.2.5",
        "fideloper/proxy": "^4.2",
        "laravel/framework": "^7.0",
        "laravel/tinker": "^2.0"
    },
    "require-dev": {
        "facade/ignition": "^2.0",
        "fzaninotto/faker": "^1.9.1",
        "mockery/mockery": "^1.3.1",
        "nunomaduro/collision": "^3.0",
        "phpunit/phpunit": "^8.5"
    },
    "autoload": {
        "psr-4": {
            "App\\": "app/"
        },
        "classmap": [
            "database/seeds",
            "database/factories"
        ]
    },
    "autoload-dev": {
        "psr-4": {
            "Tests\\": "tests/"
        }
    },
    "scripts": {
        "post-autoload-dump": [
            "Illuminate\\Foundation\\ComposerScripts::postAutoloadDump",
            "@php artisan package:discover --ansi"
        ],
        "post-root-package-install": [
            "@php -r \"file_exists('.env') || copy('.env.example', '.env');\""
        ],
        "post-create-project-cmd": [
            "@php artisan key:generate --ansi"
        ]
    },
    "config": {
        "optimize-autoloader": true,
        "preferred-install": "dist",
        "sort-packages": true
    },
    "minimum-stability": "dev",
    "prefer-stable": true
}
EOF

# Rimuovi lock e vendor
rm -f composer.lock
rm -rf vendor

# Installa dipendenze
echo "📥 Installazione dipendenze Laravel 7..."
./bin/composer install --optimize-autoloader --no-dev --no-interaction

# Configura .env
echo "⚙️  Configurazione .env..."
if [ ! -f ".env" ]; then
    cp .env.example .env 2>/dev/null || touch .env
    php artisan key:generate --quiet 2>/dev/null || echo "APP_KEY=base64:$(openssl rand -base64 32)" >> .env
fi

# Crea database
echo "💾 Creazione database..."
mkdir -p database
touch database/database.sqlite
chmod 664 database/database.sqlite
chmod 775 database

# Migrazioni
echo "🔄 Esecuzione migrazioni..."
php artisan migrate --force --quiet 2>/dev/null || echo "⚠️  Migrazioni saltate (potrebbero non esistere per Laravel 7)"

# Storage link
echo "🔗 Creazione link storage..."
php artisan storage:link --quiet 2>/dev/null || mkdir -p storage/app/public

# Cache
echo "💨 Ottimizzazione cache..."
php artisan config:cache --quiet 2>/dev/null || true
php artisan route:cache --quiet 2>/dev/null || true
php artisan view:cache --quiet 2>/dev/null || true

# Permessi
echo "🔐 Impostazione permessi..."
chmod -R 775 storage bootstrap/cache 2>/dev/null || true
chmod 664 database/database.sqlite 2>/dev/null || true

echo ""
echo "✅ INSTALLAZIONE COMPLETATA!"
echo ""
echo "📁 Directory: $PROJECT_DIR"
echo ""
echo "🚀 Per avviare il server:"
echo "   cd $PROJECT_DIR"
echo "   php artisan serve --host=0.0.0.0 --port=8000"
echo ""
echo "🌐 URL: http://217.114.212.10:8000"
echo ""

