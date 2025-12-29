# 📦 Compilazione Asset Localmente

Se non puoi installare Node.js sul server, compila gli asset sul tuo computer locale e caricali.

## Passi:

### 1. Sul tuo computer locale (Windows):

```bash
# Assicurati di essere nella directory del progetto
cd C:\Users\user\Documents\funtasting

# Installa dipendenze (se non l'hai già fatto)
npm install

# Compila gli asset
npm run build
```

### 2. Verifica che gli asset siano stati compilati:

Dovresti vedere la cartella `public/build` con:
- `manifest.json`
- `assets/app-*.js`
- `assets/app-*.css`

### 3. Carica gli asset sul server:

**Opzione A: Usa SCP (da Windows con Git Bash o WSL):**
```bash
scp -r public/build funtasting@tuo-server:/home/funtasting/www/funtasting/public/
```

**Opzione B: Usa SFTP (FileZilla, WinSCP, ecc.):**
- Connettiti al server
- Vai in `/home/funtasting/www/funtasting/public/`
- Carica la cartella `build` dalla tua macchina locale

**Opzione C: Usa Git (temporaneamente rimuovi .gitignore):**
```bash
# Localmente, modifica temporaneamente .gitignore
# Rimuovi la riga: /public/build

# Committa gli asset
git add public/build
git commit -m "Aggiungi asset compilati"
git push origin main

# Sul server
cd ~/www/funtasting
git pull origin main

# Ripristina .gitignore
```

### 4. Verifica sul server:

```bash
cd ~/www/funtasting
ls -la public/build/
```

Dovresti vedere i file compilati.

## ✅ Vantaggi:
- Non serve Node.js sul server
- Compilazione più veloce sul tuo PC
- Controllo completo del processo

## ⚠️ Nota:
Ogni volta che modifichi CSS/JS, devi ricompilare e ricaricare.

