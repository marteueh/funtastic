#!/bin/bash

# ============================================
# SCRIPT INSTALLAZIONE COMPLETA FUNTASTING
# Compatibile PHP 7.4
# ============================================

set -e  # Esce in caso di errore

echo "🚀 Installazione FUNTASTING - PHP 7.4"
echo "======================================"

# Directory
INSTALL_DIR="/home/users/fantasting/www"
PROJECT_DIR="$INSTALL_DIR/funtasting"

# Vai in www
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

# Modifica composer.json per PHP 7.4
echo "🔧 Configurazione composer.json per PHP 7.4..."
cat > composer.json << 'EOF'
{
    "$schema": "https://getcomposer.org/schema.json",
    "name": "laravel/laravel",
    "type": "project",
    "description": "The skeleton application for the Laravel framework.",
    "keywords": ["laravel", "framework"],
    "license": "MIT",
    "require": {
        "php": "^7.4|^8.0",
        "laravel/framework": "^8.83",
        "laravel/sanctum": "^2.15",
        "laravel/tinker": "^2.7"
    },
    "require-dev": {
        "fakerphp/faker": "^1.9.1",
        "laravel/pint": "^1.0",
        "laravel/sail": "^1.0.1",
        "mockery/mockery": "^1.4.2",
        "nunomaduro/collision": "^5.0",
        "phpunit/phpunit": "^9.3"
    },
    "autoload": {
        "psr-4": {
            "App\\": "app/",
            "Database\\Factories\\": "database/factories/",
            "Database\\Seeders\\": "database/seeders/"
        }
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
        "post-update-cmd": [
            "@php artisan vendor:publish --tag=laravel-assets --ansi --force"
        ],
        "post-root-package-install": [
            "@php -r \"file_exists('.env') || copy('.env.example', '.env');\""
        ],
        "post-create-project-cmd": [
            "@php artisan key:generate --ansi"
        ]
    },
    "extra": {
        "laravel": {
            "dont-discover": []
        }
    },
    "config": {
        "optimize-autoloader": true,
        "preferred-install": "dist",
        "sort-packages": true,
        "allow-plugins": {
            "pestphp/pest-plugin": true,
            "php-http/discovery": true
        }
    },
    "minimum-stability": "stable",
    "prefer-stable": true
}
EOF

# Rimuovi composer.lock
rm -f composer.lock

# Installa dipendenze
echo "📥 Installazione dipendenze (può richiedere alcuni minuti)..."
./bin/composer install --optimize-autoloader --no-dev --no-interaction

# Configura .env
echo "⚙️  Configurazione .env..."
if [ ! -f ".env" ]; then
    cp .env.example .env
    php artisan key:generate --quiet
fi

# Crea database
echo "💾 Creazione database..."
mkdir -p database
touch database/database.sqlite
chmod 664 database/database.sqlite
chmod 775 database

# Migrazioni
echo "🔄 Esecuzione migrazioni..."
php artisan migrate --force --quiet

# Storage link
echo "🔗 Creazione link storage..."
php artisan storage:link --quiet

# Cache
echo "💨 Ottimizzazione cache..."
php artisan config:cache --quiet
php artisan route:cache --quiet
php artisan view:cache --quiet

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

