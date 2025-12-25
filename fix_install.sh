#!/bin/bash

# Fix immediato - Rimuove require-dev e installa
cd /home/users/fantasting/www/funtasting

# Rimuovi require-dev da composer.json
php -r "
\$json = json_decode(file_get_contents('composer.json'), true);
unset(\$json['require-dev']);
file_put_contents('composer.json', json_encode(\$json, JSON_PRETTY_PRINT | JSON_UNESCAPED_SLASHES));
"

# Rimuovi vendor e lock
rm -rf vendor composer.lock

# Installa
./bin/composer install --optimize-autoloader --no-interaction --no-audit

# Verifica
if [ -f "vendor/autoload.php" ]; then
    echo "✅ SUCCESSO! vendor/autoload.php creato"
    php artisan serve --host=0.0.0.0 --port=8000
else
    echo "❌ ERRORE: vendor/autoload.php non creato"
    echo "Esegui: ./bin/composer install --optimize-autoloader --no-interaction --no-audit"
fi

