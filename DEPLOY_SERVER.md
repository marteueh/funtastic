# 🖥️ Guida Deploy su Server Proprio

## 📋 Requisiti Server

- **OS:** Ubuntu 20.04/22.04 o Debian 11/12 (consigliato)
- **RAM:** Minimo 1GB (consigliato 2GB+)
- **Storage:** Minimo 10GB
- **PHP:** 8.2 o superiore
- **Database:** MySQL 8.0+ o PostgreSQL 13+
- **Web Server:** Nginx o Apache

## 🚀 Installazione Completa

### 1. Aggiorna il Sistema

```bash
sudo apt update
sudo apt upgrade -y
```

### 2. Installa PHP 8.2 e Estensioni

```bash
sudo apt install -y software-properties-common
sudo add-apt-repository ppa:ondrej/php -y
sudo apt update

sudo apt install -y php8.2 php8.2-fpm php8.2-cli php8.2-common \
    php8.2-mysql php8.2-zip php8.2-gd php8.2-mbstring \
    php8.2-curl php8.2-xml php8.2-bcmath php8.2-intl \
    php8.2-readline php8.2-tokenizer
```

### 3. Installa Composer

```bash
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer
sudo chmod +x /usr/local/bin/composer
```

### 4. Installa Node.js e npm

```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs
```

### 5. Installa MySQL

```bash
sudo apt install -y mysql-server
sudo mysql_secure_installation
```

### 6. Installa Nginx

```bash
sudo apt install -y nginx
sudo systemctl start nginx
sudo systemctl enable nginx
```

## 📦 Trasferimento Progetto

### Opzione A: Da Git (Consigliato)

```bash
cd /var/www
sudo git clone https://github.com/TUO_USERNAME/funtasting.git
sudo chown -R www-data:www-data funtasting
cd funtasting
```

### Opzione B: Trasferimento File (FTP/SFTP/SCP)

1. Comprimi il progetto localmente:
   ```bash
   # Sul tuo PC Windows
   tar -czf funtasting.tar.gz --exclude='node_modules' --exclude='vendor' --exclude='.git' funtasting
   ```

2. Trasferisci sul server:
   ```bash
   # Dal tuo PC
   scp funtasting.tar.gz user@tuo-server:/tmp/
   ```

3. Sul server:
   ```bash
   cd /var/www
   sudo tar -xzf /tmp/funtasting.tar.gz
   sudo chown -R www-data:www-data funtasting
   cd funtasting
   ```

## ⚙️ Configurazione Progetto

### 1. Installa Dipendenze

```bash
composer install --optimize-autoloader --no-dev
npm install
npm run build
```

### 2. Configura File .env

```bash
cp .env.example .env
nano .env
```

Configura queste variabili:

```env
APP_NAME="FUNTASTING"
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_URL=http://tuo-dominio.com

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=funtasting
DB_USERNAME=funtasting_user
DB_PASSWORD=tua_password_sicura

LOG_CHANNEL=stack
LOG_LEVEL=error

SESSION_DRIVER=database
SESSION_LIFETIME=120
```

### 3. Genera APP_KEY

```bash
php artisan key:generate
```

### 4. Crea Database

```bash
sudo mysql -u root -p
```

Nel MySQL prompt:

```sql
CREATE DATABASE funtasting CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'funtasting_user'@'localhost' IDENTIFIED BY 'tua_password_sicura';
GRANT ALL PRIVILEGES ON funtasting.* TO 'funtasting_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

### 5. Esegui Migrazioni

```bash
php artisan migrate --force
php artisan db:seed
```

### 6. Linka Storage

```bash
php artisan storage:link
```

### 7. Ottimizza per Produzione

```bash
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

### 8. Imposta Permessi

```bash
sudo chown -R www-data:www-data /var/www/funtasting
sudo chmod -R 755 /var/www/funtasting
sudo chmod -R 775 /var/www/funtasting/storage
sudo chmod -R 775 /var/www/funtasting/bootstrap/cache
```

## 🌐 Configurazione Nginx

### 1. Crea Configurazione Nginx

```bash
sudo nano /etc/nginx/sites-available/funtasting
```

Incolla questa configurazione:

```nginx
server {
    listen 80;
    listen [::]:80;
    server_name tuo-dominio.com www.tuo-dominio.com;
    root /var/www/funtasting/public;

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
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~ /\.(?!well-known).* {
        deny all;
    }
}
```

**Sostituisci `tuo-dominio.com` con il tuo dominio!**

### 2. Abilita il Sito

```bash
sudo ln -s /etc/nginx/sites-available/funtasting /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

## 🔒 Configurazione SSL (Let's Encrypt)

### 1. Installa Certbot

```bash
sudo apt install -y certbot python3-certbot-nginx
```

### 2. Ottieni Certificato SSL

```bash
sudo certbot --nginx -d tuo-dominio.com -d www.tuo-dominio.com
```

### 3. Aggiorna APP_URL nel .env

```bash
nano .env
```

Cambia:
```env
APP_URL=https://tuo-dominio.com
```

Poi:
```bash
php artisan config:cache
```

## 🔄 Aggiornamenti Futuri

Quando aggiorni il progetto:

```bash
cd /var/www/funtasting
git pull origin main  # Se usi Git
# oppure trasferisci i nuovi file

composer install --optimize-autoloader --no-dev
npm install
npm run build
php artisan migrate --force
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

## 🛠️ Comandi Utili

### Riavvia Servizi

```bash
sudo systemctl restart nginx
sudo systemctl restart php8.2-fpm
sudo systemctl restart mysql
```

### Controlla Log

```bash
# Log Nginx
sudo tail -f /var/log/nginx/error.log

# Log Laravel
tail -f /var/www/funtasting/storage/logs/laravel.log

# Log PHP-FPM
sudo tail -f /var/log/php8.2-fpm.log
```

### Clear Cache

```bash
cd /var/www/funtasting
php artisan config:clear
php artisan route:clear
php artisan view:clear
php artisan cache:clear
```

## 🔐 Sicurezza

1. **Firewall:**
   ```bash
   sudo ufw allow 22/tcp
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp
   sudo ufw enable
   ```

2. **Fail2Ban (opzionale ma consigliato):**
   ```bash
   sudo apt install -y fail2ban
   sudo systemctl enable fail2ban
   ```

3. **Backup Database:**
   ```bash
   mysqldump -u funtasting_user -p funtasting > backup_$(date +%Y%m%d).sql
   ```

## ✅ Checklist Finale

- [ ] PHP 8.2+ installato
- [ ] Composer installato
- [ ] Node.js installato
- [ ] MySQL installato e configurato
- [ ] Nginx installato e configurato
- [ ] Progetto trasferito su server
- [ ] Dipendenze installate
- [ ] File .env configurato
- [ ] Database creato
- [ ] Migrazioni eseguite
- [ ] Permessi impostati correttamente
- [ ] Nginx configurato
- [ ] SSL configurato (opzionale)
- [ ] Firewall configurato
- [ ] Backup configurato

## 🆘 Troubleshooting

### Errore 502 Bad Gateway
```bash
sudo systemctl restart php8.2-fpm
sudo systemctl status php8.2-fpm
```

### Errore 500 Internal Server Error
- Controlla i log: `tail -f storage/logs/laravel.log`
- Verifica permessi: `ls -la storage bootstrap/cache`
- Verifica .env: `php artisan config:clear && php artisan config:cache`

### Database non connesso
- Verifica credenziali in .env
- Testa connessione: `mysql -u funtasting_user -p funtasting`

### Asset non caricati
```bash
npm run build
php artisan storage:link
```

