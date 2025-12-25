# 🚀 Guida Passo-Passo al Deploy

## Fase 1: Preparazione GitHub

### 1.1 Crea un repository su GitHub

1. Vai su [github.com](https://github.com) e accedi
2. Clicca sul pulsante **"+"** in alto a destra → **"New repository"**
3. Compila i campi:
   - **Repository name:** `funtasting` (o un nome a tua scelta)
   - **Description:** "Marketplace esperienziale per le Marche"
   - **Visibility:** Scegli Public o Private
   - **NON** spuntare "Initialize with README" (abbiamo già i file)
4. Clicca **"Create repository"**

### 1.2 Collega il repository locale

GitHub ti mostrerà delle istruzioni. Esegui questi comandi nel terminale:

```bash
git remote add origin https://github.com/TUO_USERNAME/funtasting.git
git branch -M main
git push -u origin main
```

**Sostituisci `TUO_USERNAME` con il tuo username GitHub!**

## Fase 2: Deploy su Railway

### 2.1 Crea account Railway

1. Vai su [railway.app](https://railway.app)
2. Clicca **"Start a New Project"**
3. Scegli **"Login with GitHub"** e autorizza Railway

### 2.2 Crea nuovo progetto

1. Clicca **"New Project"**
2. Seleziona **"Deploy from GitHub repo"**
3. Autorizza Railway ad accedere ai tuoi repository
4. Seleziona il repository `funtasting`
5. Railway inizierà automaticamente il deploy

### 2.3 Aggiungi Database

1. Nel dashboard Railway, clicca **"+ New"**
2. Seleziona **"Database"** → **"Add MySQL"** (o PostgreSQL)
3. Railway creerà automaticamente il database

### 2.4 Configura Variabili d'Ambiente

1. Nel tuo progetto Railway, vai su **"Variables"**
2. Aggiungi queste variabili:

```
APP_NAME=FUNTASTING
APP_ENV=production
APP_DEBUG=false
APP_URL=https://tuoprogetto.railway.app
APP_KEY=base64:RiwK9RKiSVN2hIfW4Z2iETRAD4FgcbFo5ZfEFcUTeOY=
```

**Per APP_KEY:** Railway potrebbe generarlo automaticamente, oppure usa quello generato.

3. Aggiungi le variabili del database (Railway le fornisce automaticamente):
   - Clicca sul database che hai creato
   - Vai su **"Variables"**
   - Copia le variabili `MYSQL_HOST`, `MYSQLDATABASE`, `MYSQLUSER`, `MYSQLPASSWORD`, `MYSQLPORT`
   - Aggiungile al progetto principale come:
     ```
     DB_CONNECTION=mysql
     DB_HOST=<MYSQL_HOST>
     DB_PORT=<MYSQLPORT>
     DB_DATABASE=<MYSQLDATABASE>
     DB_USERNAME=<MYSQLUSER>
     DB_PASSWORD=<MYSQLPASSWORD>
     ```

### 2.5 Configura Build e Deploy

Railway dovrebbe rilevare automaticamente Laravel. Se non funziona:

1. Vai su **"Settings"** del progetto
2. In **"Build Command"** aggiungi:
   ```
   composer install --no-dev --optimize-autoloader && npm install && npm run build
   ```
3. In **"Start Command"** aggiungi:
   ```
   php artisan migrate --force && php artisan storage:link && php artisan serve --host=0.0.0.0 --port=$PORT
   ```

### 2.6 Esegui Migrazioni

1. Vai su **"Deployments"**
2. Clicca sul deployment più recente
3. Apri la console
4. Esegui:
   ```bash
   php artisan migrate --force
   php artisan db:seed
   ```

### 2.7 Ottieni il Dominio

1. Nel dashboard del progetto, vai su **"Settings"**
2. In **"Domains"**, clicca **"Generate Domain"**
3. Railway ti darà un URL tipo: `tuoprogetto.railway.app`
4. Aggiorna `APP_URL` con questo dominio

## Fase 3: Verifica

1. Visita il tuo dominio Railway
2. Dovresti vedere la homepage di FUNTASTING
3. Prova a fare login con:
   - `admin@funtasting.it` / `password`

## Problemi Comuni

### Errore 500
- Verifica che `APP_KEY` sia impostato
- Controlla i log in Railway → "Deployments" → "View Logs"

### Database non connesso
- Verifica le variabili d'ambiente del database
- Assicurati che il database sia nello stesso progetto Railway

### Asset non caricati
- Verifica che `npm run build` sia eseguito
- Controlla che `public/build` esista

## Supporto

Se hai problemi, controlla:
- Log di Railway (Deployments → View Logs)
- Log Laravel (storage/logs/laravel.log)

