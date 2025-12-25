# 🚀 Guida Deploy FUNTASTING - Percorso Corretto

## 📋 Struttura Server
- Directory: `/home/users/fantasting/www`
- Utente: `fantasting`
- IP: `217.114.212.10`

---

## FASE 1: Prepara il Progetto sul Tuo PC

### 1. Compila gli Asset

```powershell
cd C:\Users\user\Documents\funtasting
npm run build
```

### 2. Comprimi il Progetto

```powershell
# Escludi node_modules
Get-ChildItem -Path . -Exclude node_modules | Compress-Archive -DestinationPath ..\funtasting-deploy.zip -Force
```

---

## FASE 2: Carica sul Server

### Via FTP/SFTP (FileZilla o WinSCP)

1. Connetti a: `217.114.212.10`
2. Username: `fantasting`
3. Carica `funtasting-deploy.zip` in `/home/users/fantasting/www/`

---

## FASE 3: Setup sul Server

### 1. Connettiti

```bash
ssh fantasting@217.114.212.10
```

### 2. Estrai il Progetto

```bash
cd /home/users/fantasting/www
unzip funtasting-deploy.zip -d funtasting
cd funtasting
```

### 3. Installa Composer

```bash
# Sei già in /home/users/fantasting/www/funtasting
curl -sS https://getcomposer.org/installer | php
mkdir -p bin
mv composer.phar bin/composer
chmod +x bin/composer
```

### 4. Installa Dipendenze PHP

```bash
./bin/composer install --optimize-autoloader --no-dev
```

### 5. Configura .env

```bash
cp .env.example .env
nano .env
```

Modifica queste righe:
```
APP_ENV=production
APP_DEBUG=false
APP_URL=http://217.114.212.10:8000

DB_CONNECTION=sqlite
DB_DATABASE=/home/users/fantasting/www/funtasting/database/database.sqlite
```

Rimuovi o commenta:
```
# DB_HOST=127.0.0.1
# DB_PORT=3306
# DB_USERNAME=
# DB_PASSWORD=
```

Salva: `Ctrl+X`, `Y`, `Enter`

### 6. Genera APP_KEY

```bash
php artisan key:generate
```

### 7. Crea Database SQLite

```bash
touch database/database.sqlite
chmod 664 database/database.sqlite
```

### 8. Esegui Migrazioni

```bash
php artisan migrate --force
php artisan db:seed --force
php artisan storage:link
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

### 9. Avvia il Server

```bash
php artisan serve --host=0.0.0.0 --port=8000
```

---

## FASE 4: Accedi al Sito

Apri il browser:
```
http://217.114.212.10:8000
```

---

## Per Mantenere il Server Sempre Attivo

```bash
# Usa screen
screen -S funtasting
cd /home/users/fantasting/www/funtasting
php artisan serve --host=0.0.0.0 --port=8000

# Staccati: Ctrl+A poi D
# Riattacca: screen -r funtasting
```

---

## Configurazione Nginx (Opzionale - per porta 80)

Se vuoi usare la porta 80 standard:

```bash
sudo nano /etc/nginx/sites-available/funtasting
```

Incolla:
```nginx
server {
    listen 80;
    server_name 217.114.212.10;
    root /home/users/fantasting/www/funtasting/public;

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
- [ ] File ZIP creato
- [ ] File caricato in `/home/users/fantasting/www/`
- [ ] Progetto estratto
- [ ] Composer installato
- [ ] Dipendenze installate
- [ ] .env configurato
- [ ] Database creato
- [ ] Migrazioni eseguite
- [ ] Server avviato
- [ ] Sito accessibile

