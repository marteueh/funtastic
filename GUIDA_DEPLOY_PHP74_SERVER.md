# 🚀 Guida Deploy su Server con PHP 7.4

## Prerequisiti

- Server Ubuntu/Linux con PHP 7.4+ installato
- Accesso SSH al server
- Git installato sul server
- Directory `/home/users/fantasting/www` accessibile

---

## Passo 1: Connettiti al Server

```bash
ssh fantasting@217.114.212.10
```

---

## Passo 2: Vai nella Directory www

```bash
cd /home/users/fantasting/www
```

---

## Passo 3: Clona il Branch PHP 7.4

```bash
# Rimuovi la vecchia directory se esiste
rm -rf funtasting

# Clona il branch php7.4-compatible
git clone -b php7.4-compatible https://github.com/marteueh/funtastic.git funtasting

# Entra nella directory
cd funtasting
```

**Se Git non è installato:**
```bash
sudo apt-get update
sudo apt-get install git -y
```

**Se non hai sudo, usa wget:**
```bash
cd /home/users/fantasting/www
wget https://github.com/marteueh/funtastic/archive/refs/heads/php7.4-compatible.zip -O funtasting.zip
unzip funtasting.zip
mv funtastic-php7.4-compatible funtasting
cd funtasting
```

---

## Passo 4: Installa Composer

```bash
cd /home/users/fantasting/www/funtasting

# Scarica Composer
curl -sS https://getcomposer.org/installer | php

# Crea directory bin se non esiste
mkdir -p bin

# Sposta Composer
mv composer.phar bin/composer
chmod +x bin/composer

# Verifica installazione
./bin/composer --version
```

**Se curl non funziona, usa wget:**
```bash
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
php composer-setup.php
php -r "unlink('composer-setup.php');"
mkdir -p bin
mv composer.phar bin/composer
chmod +x bin/composer
```

---

## Passo 5: Installa Dipendenze PHP

```bash
cd /home/users/fantasting/www/funtasting

# Installa dipendenze (senza dev)
./bin/composer install --optimize-autoloader --no-dev --no-interaction
```

**Se ci sono errori di memoria:**
```bash
./bin/composer install --optimize-autoloader --no-dev --no-interaction --no-scripts
```

---

## Passo 6: Configura .env

```bash
cd /home/users/fantasting/www/funtasting

# Copia .env.example
cp .env.example .env

# Modifica .env
nano .env
```

**Configurazione minima per .env:**

```env
APP_NAME=FUNTASTING
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_URL=http://217.114.212.10:8000

LOG_CHANNEL=stack
LOG_LEVEL=error

DB_CONNECTION=sqlite
DB_DATABASE=/home/users/fantasting/www/funtasting/database/database.sqlite

BROADCAST_DRIVER=log
CACHE_DRIVER=file
FILESYSTEM_DISK=local
QUEUE_CONNECTION=sync
SESSION_DRIVER=file
SESSION_LIFETIME=120

MEMCACHED_HOST=127.0.0.1

REDIS_HOST=127.0.0.1
REDIS_PASSWORD=null
REDIS_PORT=6379

MAIL_MAILER=smtp
MAIL_HOST=mailpit
MAIL_PORT=1025
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
MAIL_FROM_ADDRESS="hello@example.com"
MAIL_FROM_NAME="${APP_NAME}"
```

**Salva:** `Ctrl+X`, poi `Y`, poi `Enter`

---

## Passo 7: Genera APP_KEY

```bash
cd /home/users/fantasting/www/funtasting
php artisan key:generate
```

---

## Passo 8: Crea Database SQLite

```bash
cd /home/users/fantasting/www/funtasting

# Crea file database
touch database/database.sqlite

# Imposta permessi
chmod 664 database/database.sqlite
chmod 775 database
```

---

## Passo 9: Esegui Migrazioni

```bash
cd /home/users/fantasting/www/funtasting

# Esegui migrazioni
php artisan migrate --force

# (Opzionale) Esegui seeder
php artisan db:seed --force
```

---

## Passo 10: Crea Link Storage

```bash
cd /home/users/fantasting/www/funtasting
php artisan storage:link
```

---

## Passo 11: Ottimizza Laravel

```bash
cd /home/users/fantasting/www/funtasting

# Cache configurazione
php artisan config:cache

# Cache route
php artisan route:cache

# Cache view
php artisan view:cache
```

---

## Passo 12: Imposta Permessi

```bash
cd /home/users/fantasting/www/funtasting

# Imposta permessi per storage e cache
chmod -R 775 storage bootstrap/cache
chown -R $USER:$USER storage bootstrap/cache
```

**Se non hai permessi per chown, salta questo passaggio.**

---

## Passo 13: Avvia il Server

### Opzione A: Server Sviluppo (Temporaneo)

```bash
cd /home/users/fantasting/www/funtasting
php artisan serve --host=0.0.0.0 --port=8000
```

**Per eseguire in background:**
```bash
nohup php artisan serve --host=0.0.0.0 --port=8000 > /dev/null 2>&1 &
```

**Per fermare:**
```bash
pkill -f "artisan serve"
```

### Opzione B: Con Nginx (Produzione)

Se hai Nginx configurato, crea un file di configurazione:

```bash
sudo nano /etc/nginx/sites-available/funtasting
```

**Contenuto:**
```nginx
server {
    listen 80;
    server_name 217.114.212.10;
    root /home/users/fantasting/www/funtasting/public;

    add_header X-Frame-Options "SAMEORIGIN";
    add_header X-Content-Type-Options "nosniff";

    index index.php;

    charset utf-8;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    error_page 404 /index.php;

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php7.4-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
```

**Abilita il sito:**
```bash
sudo ln -s /etc/nginx/sites-available/funtasting /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

---

## Passo 14: Verifica Installazione

Apri il browser e vai su:
- **Con artisan serve:** `http://217.114.212.10:8000`
- **Con Nginx:** `http://217.114.212.10`

---

## Troubleshooting

### Errore: "Composer could not find a composer.json"
**Soluzione:** Verifica di essere nella directory corretta:
```bash
pwd
# Dovrebbe essere: /home/users/fantasting/www/funtasting
ls composer.json
```

### Errore: "PHP version does not satisfy requirement"
**Soluzione:** Verifica versione PHP:
```bash
php -v
# Dovrebbe essere PHP 7.4 o superiore
```

### Errore: "Permission denied"
**Soluzione:** Imposta permessi:
```bash
chmod -R 775 storage bootstrap/cache
chmod 664 database/database.sqlite
```

### Errore: "Class not found"
**Soluzione:** Rigenera autoload:
```bash
./bin/composer dump-autoload
php artisan config:clear
php artisan cache:clear
```

### Errore: "SQLSTATE[HY000] [14] unable to open database file"
**Soluzione:** Verifica permessi database:
```bash
ls -la database/database.sqlite
chmod 664 database/database.sqlite
chmod 775 database
```

---

## Aggiornamenti Futuri

Per aggiornare il progetto:

```bash
cd /home/users/fantasting/www/funtasting

# Pull ultime modifiche
git pull origin php7.4-compatible

# Aggiorna dipendenze
./bin/composer install --optimize-autoloader --no-dev --no-interaction

# Esegui nuove migrazioni
php artisan migrate --force

# Ricarica cache
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

---

## Script Completo (Copia e Incolla)

Se preferisci, ecco uno script completo:

```bash
#!/bin/bash

# Vai in www
cd /home/users/fantasting/www

# Rimuovi vecchia installazione
rm -rf funtasting

# Clona branch
git clone -b php7.4-compatible https://github.com/marteueh/funtastic.git funtasting

cd funtasting

# Installa Composer
curl -sS https://getcomposer.org/installer | php
mkdir -p bin
mv composer.phar bin/composer
chmod +x bin/composer

# Installa dipendenze
./bin/composer install --optimize-autoloader --no-dev --no-interaction

# Configura .env
cp .env.example .env
php artisan key:generate

# Crea database
touch database/database.sqlite
chmod 664 database/database.sqlite

# Migrazioni
php artisan migrate --force

# Storage link
php artisan storage:link

# Cache
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Permessi
chmod -R 775 storage bootstrap/cache

echo "✅ Installazione completata!"
echo "Avvia con: php artisan serve --host=0.0.0.0 --port=8000"
```

**Salva come `deploy.sh` e esegui:**
```bash
chmod +x deploy.sh
./deploy.sh
```

---

## ✅ Fine!

Il progetto è ora online e accessibile all'indirizzo del tuo server!

