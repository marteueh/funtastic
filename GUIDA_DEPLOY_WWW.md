# 🚀 Guida Deploy FUNTASTING in /www

## 📋 Requisiti
- Server Ubuntu con IP: 217.114.212.10
- Utente: fantasting
- Directory: /www o /var/www

---

## FASE 1: Prepara il Progetto sul Tuo PC

### 1. Compila gli Asset (sul PC Windows)

```powershell
cd C:\Users\user\Documents\funtasting
npm run build
```

### 2. Comprimi il Progetto

```powershell
# Escludi solo node_modules
Get-ChildItem -Path . -Exclude node_modules | Compress-Archive -DestinationPath ..\funtasting-deploy.zip -Force
```

---

## FASE 2: Carica sul Server

### Via FTP/SFTP (FileZilla o WinSCP)

1. Connetti a: `217.114.212.10`
2. Username: `fantasting`
3. Carica `funtasting-deploy.zip` in `/www/` o `/var/www/`

---

## FASE 3: Setup sul Server

### 1. Connettiti al Server

```bash
ssh fantasting@217.114.212.10
```

### 2. Verifica la directory www

```bash
# Prova /www
ls -la /www

# Se non esiste, prova /var/www
ls -la /var/www
```

### 3. Estrai il Progetto

```bash
# Se /www esiste:
cd /www
unzip funtasting-deploy.zip -d funtasting
cd funtasting

# Oppure se /var/www:
cd /var/www
unzip funtasting-deploy.zip -d funtasting
cd funtasting
```

### 4. Installa Composer

```bash
cd /tmp
curl -sS https://getcomposer.org/installer | php
mkdir -p /tmp/composer
mv composer.phar /tmp/composer/composer
chmod +x /tmp/composer/composer
export PATH="/tmp/composer:$PATH"
```

### 5. Installa Dipendenze PHP

```bash
# Torna nella directory del progetto
cd /www/funtasting  # oppure /var/www/funtasting
/tmp/composer/composer install --optimize-autoloader --no-dev
```

### 6. Configura .env

```bash
cp .env.example .env
nano .env
```

Modifica:
```
APP_ENV=production
APP_DEBUG=false
APP_URL=http://217.114.212.10:8000

DB_CONNECTION=sqlite
DB_DATABASE=/www/funtasting/database/database.sqlite
```

(Oppure `/var/www/funtasting/database/database.sqlite` se usi /var/www)

Salva: `Ctrl+X`, `Y`, `Enter`

### 7. Genera APP_KEY

```bash
php artisan key:generate
```

### 8. Crea Database SQLite

```bash
touch database/database.sqlite
chmod 664 database/database.sqlite
```

### 9. Esegui Migrazioni

```bash
php artisan migrate --force
php artisan db:seed --force
php artisan storage:link
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

### 10. Avvia il Server

```bash
php artisan serve --host=0.0.0.0 --port=8000
```

---

## FASE 4: Configura Nginx (Opzionale - per porta 80)

Se vuoi usare la porta 80 invece di 8000, configura Nginx:

```bash
# Crea configurazione Nginx
sudo nano /etc/nginx/sites-available/funtasting
```

Incolla:
```nginx
server {
    listen 80;
    server_name 217.114.212.10;
    root /www/funtasting/public;  # oppure /var/www/funtasting/public

    index index.php;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.2-fpm.sock;
        fastcgi_param SCRIPT_FILENAME $realpath_root$fastcgi_script_name;
        include fastcgi_params;
    }
}
```

Abilita:
```bash
sudo ln -s /etc/nginx/sites-available/funtasting /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

---

## Checklist

- [ ] Asset compilati sul PC
- [ ] Progetto compresso
- [ ] File caricato in /www o /var/www
- [ ] Progetto estratto
- [ ] Composer installato
- [ ] Dipendenze installate
- [ ] .env configurato
- [ ] Database creato
- [ ] Migrazioni eseguite
- [ ] Server avviato
- [ ] Sito accessibile

