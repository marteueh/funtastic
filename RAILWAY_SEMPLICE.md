# 🚀 Guida Railway - Versione Semplificata

## Passo 1: Vai su Railway

1. Apri: https://railway.app
2. Login con GitHub
3. Clicca "New Project"
4. Seleziona "Deploy from GitHub repo"
5. Scegli il repository `funtastic`

## Passo 2: Aggiungi Database

1. Nel dashboard, clicca "+ New"
2. Seleziona "Database"
3. Clicca "Add MySQL"
4. Railway creerà il database automaticamente

## Passo 3: Variabili d'Ambiente (SOLO 2 da aggiungere manualmente!)

Nel progetto web (non nel database), vai su "Variables" e aggiungi SOLO queste:

### Variabile 1: APP_KEY
- Name: `APP_KEY`
- Value: `base64:RiwK9RKiSVN2hIfW4Z2iETRAD4FgcbFo5ZfEFcUTeOY=`
- Clicca "Add"

### Variabile 2: APP_URL (dopo aver ottenuto il dominio)
- Name: `APP_URL`
- Value: `https://tuoprogetto.railway.app` (lo aggiornerai dopo)
- Clicca "Add"

## Passo 4: Variabili Database (AUTOMATICHE!)

Railway può collegare automaticamente il database. Fai così:

1. Nel progetto web, vai su "Variables"
2. Cerca "Connect Database" o "Add from Service"
3. Seleziona il database MySQL che hai creato
4. Railway aggiungerà automaticamente:
   - `MYSQL_HOST`
   - `MYSQLDATABASE`
   - `MYSQLUSER`
   - `MYSQLPASSWORD`
   - `MYSQLPORT`

5. **IMPORTANTE**: Railway aggiunge queste variabili con nomi diversi. Devi crearle manualmente con i nomi che Laravel si aspetta:

   - Clicca "New Variable"
   - Name: `DB_CONNECTION`, Value: `mysql`
   - Name: `DB_HOST`, Value: `${{MySQL.MYSQLHOST}}` (Railway usa questo formato)
   - Name: `DB_PORT`, Value: `${{MySQL.MYSQLPORT}}`
   - Name: `DB_DATABASE`, Value: `${{MySQL.MYSQLDATABASE}}`
   - Name: `DB_USERNAME`, Value: `${{MySQL.MYSQLUSER}}`
   - Name: `DB_PASSWORD`, Value: `${{MySQL.MYSQLPASSWORD}}`

   **OPPURE** copia i valori reali dal database e incollali direttamente.

## Passo 5: Copia Valori dal Database

Se il formato `${{MySQL.XXX}}` non funziona:

1. Vai sul database MySQL → "Variables"
2. Copia i VALORI (non le chiavi) di:
   - `MYSQLHOST` (o `MYSQL_HOST`)
   - `MYSQLPORT` (o `MYSQL_PORT`)
   - `MYSQLDATABASE`
   - `MYSQLUSER`
   - `MYSQLPASSWORD`

3. Nel progetto web → "Variables", aggiungi:
   - `DB_CONNECTION` = `mysql`
   - `DB_HOST` = `<valore copiato di MYSQLHOST>`
   - `DB_PORT` = `<valore copiato di MYSQLPORT>`
   - `DB_DATABASE` = `<valore copiato di MYSQLDATABASE>`
   - `DB_USERNAME` = `<valore copiato di MYSQLUSER>`
   - `DB_PASSWORD` = `<valore copiato di MYSQLPASSWORD>`

## Passo 6: Aggiungi Altre Variabili Base

Aggiungi anche:
- `APP_ENV` = `production`
- `APP_DEBUG` = `false`
- `APP_NAME` = `FUNTASTING`

## Passo 7: Ottieni Dominio

1. Settings → "Domains"
2. Clicca "Generate Domain"
3. Railway ti darà un URL tipo: `tuoprogetto.railway.app`
4. Aggiorna `APP_URL` con questo URL

## Passo 8: Esegui Migrazioni

1. Vai su "Deployments"
2. Clicca sul deployment più recente
3. Apri "Console"
4. Esegui:
   ```bash
   php artisan migrate --force
   php artisan db:seed
   ```

## ✅ Fine!

Il sito sarà disponibile all'URL che Railway ti ha dato!

---

## Se le Variabili Database sono Troppo Complesse

**Alternativa Semplice**: Usa SQLite invece di MySQL!

Nel progetto web → "Variables", aggiungi:
- `DB_CONNECTION` = `sqlite`
- `DB_DATABASE` = `/tmp/database.sqlite`

E Railway funzionerà senza bisogno di MySQL!

