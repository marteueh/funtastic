# 🚀 Guida Deploy FUNTASTING su Server con PHP 8.3

## 📋 Prerequisiti Verificati
- ✅ PHP 8.3 installato
- ✅ Accesso SSH al server
- ✅ Database MySQL configurato

## 📝 Passo 1: Verifica PHP e Installazione Dipendenze

Connettiti al server via SSH e verifica:

```bash
# Verifica versione PHP
php -v

# Dovrebbe mostrare PHP 8.3.x
```

Se PHP 8.3 non è attivo, imposta la versione predefinita:
```bash
sudo update-alternatives --set php /usr/bin/php8.3
```

## 📝 Passo 2: Installa Composer (se non presente)

```bash
# Verifica se Composer è installato
composer --version

# Se non presente, installalo:
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
sudo chmod +x /usr/local/bin/composer
```

## 📝 Passo 3: Installa Node.js e npm (se non presenti)

```bash
# Verifica se Node.js è installato
node --version
npm --version

# Se non presente, installalo:
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
```

## 📝 Passo 4: Prepara Directory di Deploy

```bash
# Vai nella directory www
cd /home/users/fantasting/www

# Se la directory funtasting esiste già, rimuovila o rinominala
# (OPZIONALE: backup della vecchia versione)
# mv funtasting funtasting_backup_$(date +%Y%m%d)

# Clona il repository (o scarica da Git)
git clone https://github.com/marteueh/funtastic.git funtasting

# Oppure se il repository esiste già, aggiornalo:
# cd funtasting
# git pull origin main
```

## 📝 Passo 5: Installa Dipendenze PHP

```bash
cd /home/users/fantasting/www/funtasting

# Installa dipendenze Composer
composer install --optimize-autoloader --no-dev

# Se hai errori di permessi, prova:
# composer install --optimize-autoloader --no-dev --no-interaction
```

## 📝 Passo 6: Configura File .env

```bash
# Copia il file .env.example
cp .env.example .env

# Modifica il file .env con le tue credenziali
nano .env
```

**Configurazione minima del file .env:**

```env
APP_NAME=FUNTASTING
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_URL=http://tuo-dominio.com

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=nome_database
DB_USERNAME=utente_database
DB_PASSWORD=password_database

# Cache e Session
CACHE_STORE=file
SESSION_DRIVER=file
QUEUE_CONNECTION=sync

# Mail (opzionale)
MAIL_MAILER=smtp
MAIL_HOST=smtp.mailtrap.io
MAIL_PORT=2525
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
MAIL_FROM_ADDRESS=hello@example.com
MAIL_FROM_NAME="${APP_NAME}"
```

## 📝 Passo 7: Genera APP_KEY

```bash
php artisan key:generate
```

Questo comando genererà automaticamente la chiave e la inserirà nel file `.env`.

## 📝 Passo 8: Crea Database MySQL

```bash
# Accedi a MySQL
mysql -u root -p

# Nel prompt MySQL, esegui:
CREATE DATABASE nome_database CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'utente_database'@'localhost' IDENTIFIED BY 'password_database';
GRANT ALL PRIVILEGES ON nome_database.* TO 'utente_database'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

**Sostituisci:**
- `nome_database` con il nome del tuo database
- `utente_database` con il nome utente
- `password_database` con la password

## 📝 Passo 9: Esegui Migrazioni e Seeder

```bash
# Esegui le migrazioni
php artisan migrate --force

# Popola il database con dati di esempio (opzionale)
php artisan db:seed
```

## 📝 Passo 10: Installa e Compila Asset Frontend

```bash
# Installa dipendenze npm
npm install

# Compila asset per produzione
npm run build
```

## 📝 Passo 11: Imposta Permessi

```bash
# Imposta i permessi corretti
sudo chown -R www-data:www-data /home/users/fantasting/www/funtasting
sudo chmod -R 755 /home/users/fantasting/www/funtasting
sudo chmod -R 775 /home/users/fantasting/www/funtasting/storage
sudo chmod -R 775 /home/users/fantasting/www/funtasting/bootstrap/cache
```

## 📝 Passo 12: Crea Link Simbolico Storage

```bash
php artisan storage:link
```

## 📝 Passo 13: Ottimizza per Produzione

```bash
# Pulisci e ottimizza cache
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

## 📝 Passo 14: Configura Nginx

Crea o modifica il file di configurazione Nginx:

```bash
sudo nano /etc/nginx/sites-available/funtasting
```

**Contenuto configurazione Nginx:**

```nginx
server {
    listen 80;
    server_name tuo-dominio.com www.tuo-dominio.com;
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
        fastcgi_pass unix:/var/run/php/php8.3-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
```

**Attiva il sito:**

```bash
# Crea link simbolico
sudo ln -s /etc/nginx/sites-available/funtasting /etc/nginx/sites-enabled/

# Testa la configurazione
sudo nginx -t

# Riavvia Nginx
sudo systemctl restart nginx
```

## 📝 Passo 15: Verifica Installazione

Apri il browser e vai a:
```
http://tuo-dominio.com
```

Oppure se non hai ancora configurato il dominio:
```
http://217.114.212.10
```

## 🔧 Troubleshooting

### Errore: "Permission denied"
```bash
sudo chown -R www-data:www-data /home/users/fantasting/www/funtasting
sudo chmod -R 755 /home/users/fantasting/www/funtasting
```

### Errore: "Vite manifest not found"
```bash
npm install
npm run build
```

### Errore: "Database connection"
- Verifica le credenziali nel file `.env`
- Verifica che MySQL sia in esecuzione: `sudo systemctl status mysql`
- Verifica che il database esista: `mysql -u root -p -e "SHOW DATABASES;"`

### Errore: "500 Internal Server Error"
```bash
# Controlla i log
tail -f /home/users/fantasting/www/funtasting/storage/logs/laravel.log

# Verifica permessi storage
sudo chmod -R 775 storage bootstrap/cache
```

## ✅ Checklist Finale

- [ ] PHP 8.3 installato e attivo
- [ ] Composer installato
- [ ] Node.js e npm installati
- [ ] Progetto clonato in `/home/users/fantasting/www/funtasting`
- [ ] Dipendenze Composer installate
- [ ] File `.env` configurato
- [ ] `APP_KEY` generato
- [ ] Database MySQL creato
- [ ] Migrazioni eseguite
- [ ] Asset frontend compilati (`npm run build`)
- [ ] Permessi impostati correttamente
- [ ] Link simbolico storage creato
- [ ] Cache ottimizzata
- [ ] Nginx configurato e riavviato
- [ ] Sito accessibile nel browser

## 🎉 Completato!

Il tuo sito FUNTASTING dovrebbe ora essere online!

