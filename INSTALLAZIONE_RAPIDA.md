# 🚀 Installazione Rapida FUNTASTING

## Script Automatico Completo

Ho creato uno script interattivo che configura **TUTTO** automaticamente.

## 📋 Cosa ti serve prima di iniziare:

1. **Accesso SSH al server** con privilegi sudo
2. **Dominio** (es. funtasting.com) o IP del server
3. **Password MySQL root** (per creare database e utente)
4. **PHP 8.2+** installato (lo script verifica e avvisa)

## 🎯 Installazione in 3 passi:

### 1. Connettiti al server via SSH

```bash
ssh tuo-utente@tuo-server
```

### 2. Scarica lo script

```bash
cd /tmp
wget https://raw.githubusercontent.com/marteueh/funtastic/main/install_completo_interattivo.sh
chmod +x install_completo_interattivo.sh
```

### 3. Esegui lo script

```bash
sudo bash install_completo_interattivo.sh
```

## 📝 Lo script ti chiederà:

1. **Directory di installazione** (default: `/var/www/funtasting`)
2. **Dominio del sito** (es. `funtasting.com`)
3. **Database Host** (default: `127.0.0.1`)
4. **Nome Database** (default: `funtasting`)
5. **Username Database** (default: `funtasting_user`)
6. **Password Database** (richiesta)
7. **Utente web server** (default: `www-data`)
8. **Password MySQL root** (per creare database)
9. **Configurare Nginx?** (s/n)

## ✅ Cosa fa lo script automaticamente:

- ✅ Verifica PHP 8.2+, Composer, Node.js, MySQL, Git
- ✅ Installa dipendenze mancanti (Composer, Node.js, Git, Nginx)
- ✅ Clona il repository GitHub
- ✅ Installa dipendenze PHP e Node.js
- ✅ Compila asset frontend
- ✅ Crea e configura file `.env`
- ✅ Genera `APP_KEY`
- ✅ Crea database MySQL e utente
- ✅ Esegue migrazioni
- ✅ Popola database con dati iniziali
- ✅ Crea link storage
- ✅ Imposta permessi corretti
- ✅ Ottimizza cache Laravel
- ✅ Configura Nginx (se richiesto)
- ✅ Riavvia servizi

## 🔐 Credenziali di default:

Dopo l'installazione, puoi accedere con:

- **Admin**: `admin@funtasting.it` / `password`
- **Vendor**: `vendor@funtasting.it` / `password`
- **Reseller**: `reseller@funtasting.it` / `password`
- **Customer**: `customer@funtasting.it` / `password`

## 🌐 Configurazione SSL (dopo installazione):

Se hai configurato Nginx, installa SSL con Let's Encrypt:

```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d tuo-dominio.com -d www.tuo-dominio.com
```

## 🆘 Problemi?

### Errore "Permission denied"
Assicurati di eseguire con `sudo`:
```bash
sudo bash install_completo_interattivo.sh
```

### Errore "PHP version"
Verifica la versione PHP:
```bash
php -v
```
Richiesto PHP 8.2 o superiore.

### Errore "MySQL connection"
Verifica che MySQL sia in esecuzione:
```bash
sudo systemctl status mysql
```

### Errore "Nginx not found"
Lo script installerà Nginx automaticamente se scegli di configurarlo.

## 📞 Supporto

Se hai problemi, controlla i log:
- Laravel: `tail -f /var/www/funtasting/storage/logs/laravel.log`
- Nginx: `sudo tail -f /var/log/nginx/error.log`
- PHP-FPM: `sudo tail -f /var/log/php8.3-fpm.log`

