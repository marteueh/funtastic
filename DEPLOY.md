# Guida al Deploy - FUNTASTING

## Opzioni di Deploy Consigliate

### 1. Railway (Consigliato per iniziare) ⭐
**Vantaggi:** Setup veloce, database incluso, HTTPS automatico, gratuito per iniziare

**Passi:**
1. Vai su [railway.app](https://railway.app) e crea un account
2. Clicca "New Project" → "Deploy from GitHub repo"
3. Connetti il repository GitHub del progetto
4. Railway rileverà automaticamente Laravel
5. Aggiungi un database PostgreSQL o MySQL
6. Configura le variabili d'ambiente:
   ```
   APP_ENV=production
   APP_DEBUG=false
   APP_KEY= (genera con: php artisan key:generate)
   DB_CONNECTION=mysql
   DB_HOST= (fornito da Railway)
   DB_PORT=3306
   DB_DATABASE= (fornito da Railway)
   DB_USERNAME= (fornito da Railway)
   DB_PASSWORD= (fornito da Railway)
   ```
7. Railway eseguirà automaticamente:
   - `composer install --no-dev`
   - `php artisan migrate`
   - `npm install && npm run build`

### 2. Laravel Forge
**Vantaggi:** Gestione completa, ottimizzato per Laravel, SSL automatico

**Passi:**
1. Iscriviti su [forge.laravel.com](https://forge.laravel.com)
2. Connetti un server (DigitalOcean, AWS, Linode, etc.)
3. Crea un nuovo sito
4. Connetti il repository Git
5. Forge configurerà automaticamente tutto

### 3. DigitalOcean App Platform
**Vantaggi:** Scalabile, gestito, database incluso

**Passi:**
1. Vai su [digitalocean.com](https://www.digitalocean.com)
2. Crea un nuovo App
3. Connetti il repository
4. Configura le variabili d'ambiente
5. Aggiungi un database MySQL/PostgreSQL

### 4. Fly.io
**Vantaggi:** Globale, veloce, buono per Laravel

**Passi:**
1. Installa Fly CLI: `curl -L https://fly.io/install.sh | sh`
2. Esegui: `fly launch`
3. Segui le istruzioni

## Preparazione Pre-Deploy

### 1. Compila gli Asset
```bash
npm run build
```

### 2. Genera APP_KEY (se non presente)
```bash
php artisan key:generate
```

### 3. Ottimizza per Produzione
```bash
php artisan config:cache
php artisan route:cache
php artisan view:cache
composer install --optimize-autoloader --no-dev
```

### 4. Variabili d'Ambiente Necessarie

Crea un file `.env.production` con:

```env
APP_NAME="FUNTASTING"
APP_ENV=production
APP_KEY=base64:... (genera con php artisan key:generate)
APP_DEBUG=false
APP_URL=https://tuodominio.com

LOG_CHANNEL=stack
LOG_LEVEL=error

DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=funtasting
DB_USERNAME=tuo_utente
DB_PASSWORD=tua_password

BROADCAST_DRIVER=log
CACHE_DRIVER=file
FILESYSTEM_DISK=local
QUEUE_CONNECTION=sync
SESSION_DRIVER=file
SESSION_LIFETIME=120

MAIL_MAILER=smtp
MAIL_HOST=mailpit
MAIL_PORT=1025
MAIL_USERNAME=null
MAIL_PASSWORD=null
MAIL_ENCRYPTION=null
MAIL_FROM_ADDRESS="hello@example.com"
MAIL_FROM_NAME="${APP_NAME}"
```

## Checklist Pre-Deploy

- [ ] Database configurato e migrazioni eseguite
- [ ] Asset compilati (`npm run build`)
- [ ] APP_KEY generato
- [ ] APP_DEBUG=false in produzione
- [ ] Variabili d'ambiente configurate
- [ ] Storage linkato (`php artisan storage:link`)
- [ ] Permessi cartelle corretti (storage, bootstrap/cache)
- [ ] Seeder eseguiti (opzionale, per dati iniziali)

## Comandi Post-Deploy

Dopo il deploy, esegui sul server:

```bash
php artisan migrate --force
php artisan storage:link
php artisan config:cache
php artisan route:cache
php artisan view:cache
```

## Note Importanti

1. **Sicurezza:** Non committare mai il file `.env`
2. **Database:** Usa sempre un database separato per produzione
3. **Backup:** Configura backup automatici del database
4. **SSL:** Assicurati che HTTPS sia abilitato
5. **Performance:** Abilita OPcache e ottimizza PHP

## Supporto

Per problemi durante il deploy, controlla i log:
- `storage/logs/laravel.log`
- Log del server web (Nginx/Apache)

