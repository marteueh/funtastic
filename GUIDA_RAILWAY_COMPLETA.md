# 🚀 Guida Completa Railway - Laravel 12

## Passo 1: Vai su Railway

1. Apri il browser e vai su: **https://railway.app**
2. Clicca su **"Login"** in alto a destra
3. Scegli **"Login with GitHub"**
4. Autorizza Railway ad accedere al tuo account GitHub

---

## Passo 2: Crea Nuovo Progetto

1. Dopo il login, vedrai la dashboard
2. Clicca sul pulsante **"+ New Project"** (in alto a destra o al centro)
3. Seleziona **"Deploy from GitHub repo"**
4. Se è la prima volta, Railway ti chiederà di autorizzare l'accesso ai repository GitHub
   - Clicca **"Authorize Railway"**
   - Seleziona il repository **"funtastic"**
   - Clicca **"Install"** o **"Authorize"**
5. Nella lista dei repository, trova e clicca su **"funtastic"**
6. Railway inizierà automaticamente il deploy

---

## Passo 3: Aggiungi Database MySQL

1. Nel dashboard del progetto, vedrai il servizio web appena creato
2. Clicca sul pulsante **"+ New"** (in alto a destra)
3. Seleziona **"Database"**
4. Clicca su **"Add MySQL"**
5. Railway creerà automaticamente un database MySQL
6. **Aspetta 1-2 minuti** che il database venga creato

---

## Passo 4: Configura Variabili d'Ambiente

### 4.1: Vai alle Variabili del Servizio Web

1. Nel dashboard, clicca sul servizio **web** (quello con il nome del tuo progetto)
2. Vai alla tab **"Variables"** (in alto, accanto a "Settings", "Deployments", ecc.)

### 4.2: Aggiungi Variabili Base

Clicca su **"New Variable"** e aggiungi queste variabili UNA PER UNA:

**Variabile 1:**
- **Name:** `APP_NAME`
- **Value:** `FUNTASTING`
- Clicca **"Add"**

**Variabile 2:**
- **Name:** `APP_ENV`
- **Value:** `production`
- Clicca **"Add"**

**Variabile 3:**
- **Name:** `APP_DEBUG`
- **Value:** `false`
- Clicca **"Add"**

**Variabile 4:**
- **Name:** `APP_KEY`
- **Value:** `base64:RiwK9RKiSVN2hIfW4Z2iETRAD4FgcbFo5ZfEFcUTeOY=`
- Clicca **"Add"**

**Variabile 5:**
- **Name:** `APP_URL`
- **Value:** `https://tuoprogetto.railway.app` (lo aggiornerai dopo)
- Clicca **"Add"**

### 4.3: Aggiungi Variabili Database

1. Vai sul servizio **Database MySQL** (clicca sul database che hai creato)
2. Vai alla tab **"Variables"**
3. **COPIA** questi valori (li userai dopo):
   - `MYSQLHOST` (o `MYSQL_HOST`)
   - `MYSQLPORT` (o `MYSQL_PORT`)
   - `MYSQLDATABASE`
   - `MYSQLUSER`
   - `MYSQLPASSWORD`

4. Torna al servizio **Web** → **Variables**
5. Aggiungi queste variabili:

**Variabile 6:**
- **Name:** `DB_CONNECTION`
- **Value:** `mysql`
- Clicca **"Add"**

**Variabile 7:**
- **Name:** `DB_HOST`
- **Value:** `<incolla qui il valore di MYSQLHOST dal database>`
- Clicca **"Add"**

**Variabile 8:**
- **Name:** `DB_PORT`
- **Value:** `<incolla qui il valore di MYSQLPORT dal database>`
- Clicca **"Add"`

**Variabile 9:**
- **Name:** `DB_DATABASE`
- **Value:** `<incolla qui il valore di MYSQLDATABASE dal database>`
- Clicca **"Add"**

**Variabile 10:**
- **Name:** `DB_USERNAME`
- **Value:** `<incolla qui il valore di MYSQLUSER dal database>`
- Clicca **"Add"`

**Variabile 11:**
- **Name:** `DB_PASSWORD`
- **Value:** `<incolla qui il valore di MYSQLPASSWORD dal database>`
- Clicca **"Add"**

---

## Passo 5: Ottieni il Dominio

1. Nel servizio **Web**, vai alla tab **"Settings"**
2. Scorri fino a **"Domains"**
3. Clicca su **"Generate Domain"**
4. Railway ti darà un URL tipo: `tuoprogetto.railway.app`
5. **COPIA** questo URL

### 5.1: Aggiorna APP_URL

1. Vai alla tab **"Variables"** del servizio Web
2. Trova la variabile `APP_URL`
3. Clicca sull'icona **matita** (edit) accanto
4. Cambia il valore con l'URL che hai copiato: `https://tuoprogetto.railway.app`
5. Clicca **"Update"**

---

## Passo 6: Esegui Migrazioni

1. Nel servizio **Web**, vai alla tab **"Deployments"**
2. Aspetta che il deployment più recente sia **"Active"** (verde)
3. Clicca sul deployment più recente
4. Vai alla tab **"Logs"** o **"Console"**
5. Se vedi **"Console"**, clicca e apri il terminale
6. Esegui questi comandi:

```bash
php artisan migrate --force
```

7. Se vuoi anche i dati di esempio:

```bash
php artisan db:seed --force
```

---

## Passo 7: Verifica

1. Vai alla tab **"Settings"** del servizio Web
2. In **"Domains"**, clicca sul link del dominio (o copia l'URL)
3. Apri l'URL nel browser
4. Dovresti vedere il sito FUNTASTING!

---

## ✅ Fine!

Il sito è ora online e accessibile all'URL che Railway ti ha dato!

---

## Troubleshooting

### Se vedi errore "APP_KEY not set":
- Vai a Variables → trova `APP_KEY` → verifica che esista
- Se non esiste, aggiungila con il valore: `base64:RiwK9RKiSVN2hIfW4Z2iETRAD4FgcbFo5ZfEFcUTeOY=`

### Se vedi errore di database:
- Verifica che tutte le variabili DB_* siano corrette
- Controlla che i valori siano copiati esattamente dal database MySQL

### Se il sito non si carica:
- Vai a Deployments → verifica che l'ultimo deployment sia "Active"
- Controlla i Logs per vedere eventuali errori

### Se le migrazioni falliscono:
- Vai a Console e esegui: `php artisan migrate:fresh --force`
- Poi: `php artisan db:seed --force`

---

## Note Importanti

- Railway ha già PHP 8.2+ installato, quindi Laravel 12 funziona perfettamente
- Il database MySQL viene creato automaticamente
- Le variabili d'ambiente sono la parte più importante - assicurati di copiarle correttamente
- Dopo ogni modifica alle variabili, Railway riavvia automaticamente il servizio

