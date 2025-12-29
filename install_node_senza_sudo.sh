#!/bin/bash

# Script per installare Node.js senza sudo usando NVM
# Esegui con: bash install_node_senza_sudo.sh

set -e

# Colori
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}╔════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   INSTALLAZIONE NODE.JS (NVM)        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════╝${NC}"
echo ""

# Verifica che non stiamo usando sudo
if [ "$EUID" -eq 0 ]; then
    echo -e "${RED}ERRORE: Non eseguire questo script con sudo!${NC}"
    exit 1
fi

# Verifica se NVM è già installato
if [ -s "$HOME/.nvm/nvm.sh" ]; then
    echo -e "${GREEN}NVM già installato. Caricamento...${NC}"
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
else
    echo -e "${GREEN}[1/3] Installazione NVM...${NC}"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    
    # Carica NVM
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
    
    echo -e "${GREEN}✓ NVM installato${NC}"
fi

# Verifica installazione NVM
if ! command -v nvm &> /dev/null; then
    echo -e "${YELLOW}Caricamento NVM manualmente...${NC}"
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
fi

# Verifica se Node.js è già installato
if command -v node &> /dev/null && [ -s "$HOME/.nvm/nvm.sh" ]; then
    NODE_VERSION=$(node -v)
    echo -e "${GREEN}Node.js già installato: $NODE_VERSION${NC}"
    read -p "Vuoi installare una nuova versione? (s/n) [n]: " INSTALL_NEW
    INSTALL_NEW=${INSTALL_NEW:-n}
    if [ "$INSTALL_NEW" != "s" ]; then
        echo -e "${GREEN}✓ Node.js già disponibile${NC}"
        exit 0
    fi
fi

# Installa Node.js LTS
echo -e "${GREEN}[2/3] Installazione Node.js LTS...${NC}"
nvm install --lts
nvm use --lts
nvm alias default node

echo -e "${GREEN}✓ Node.js installato${NC}"

# Verifica installazione
echo -e "${GREEN}[3/3] Verifica installazione...${NC}"
NODE_VERSION=$(node -v)
NPM_VERSION=$(npm -v)
echo -e "${GREEN}✓ Node.js: $NODE_VERSION${NC}"
echo -e "${GREEN}✓ npm: $NPM_VERSION${NC}"

# Aggiungi NVM al .bashrc se non presente
if ! grep -q "NVM_DIR" ~/.bashrc 2>/dev/null; then
    echo -e "${GREEN}Aggiunta configurazione NVM a .bashrc...${NC}"
    echo '' >> ~/.bashrc
    echo '# NVM Configuration' >> ~/.bashrc
    echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc
    echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> ~/.bashrc
    echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> ~/.bashrc
    echo -e "${GREEN}✓ Configurazione aggiunta a .bashrc${NC}"
fi

echo ""
echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     ✅ INSTALLAZIONE COMPLETATA!      ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}📋 PROSSIMI PASSI:${NC}"
echo -e "${BLUE}─────────────────────────────────────${NC}"
echo -e "1. Riavvia la sessione SSH o esegui:"
echo -e "   ${GREEN}source ~/.bashrc${NC}"
echo -e ""
echo -e "2. Verifica che Node.js funzioni:"
echo -e "   ${GREEN}node -v${NC}"
echo -e "   ${GREEN}npm -v${NC}"
echo -e ""
echo -e "3. Continua con l'installazione FUNTASTING:"
echo -e "   ${GREEN}bash install_senza_sudo.sh${NC}"
echo ""

