# 📦 Installazione Node.js senza Sudo (NVM)

Puoi installare Node.js nella tua home directory usando NVM (Node Version Manager).

## Installazione NVM:

```bash
# Scarica e installa NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# Riavvia la sessione SSH o esegui:
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Verifica installazione
nvm --version
```

## Installazione Node.js:

```bash
# Installa l'ultima versione LTS
nvm install --lts

# Usa la versione installata
nvm use --lts

# Verifica
node -v
npm -v
```

## Aggiungi NVM al tuo .bashrc (per renderlo permanente):

```bash
echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc
echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc
echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> ~/.bashrc

# Riavvia la sessione SSH
```

## Dopo l'installazione:

Torna allo script di installazione:
```bash
cd ~/www/funtasting
npm install
npm run build
```

## ✅ Vantaggi:
- Installazione nella home directory (no sudo)
- Gestione facile delle versioni Node.js
- Funziona per tutti i progetti futuri

## ⚠️ Nota:
Se NVM non funziona, prova a installare Node.js direttamente nella home directory usando i binari precompilati.

