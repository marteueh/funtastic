# 🚀 Installazione Automatica - Istruzioni

## Cosa fare sul server:

### Opzione 1: Scarica e esegui lo script

```bash
cd /home/users/fantasting/www
wget https://raw.githubusercontent.com/marteueh/funtastic/main/install_completo.sh
chmod +x install_completo.sh
./install_completo.sh
```

### Opzione 2: Copia lo script direttamente

1. Apri il file `install_completo.sh` che ho creato
2. Copia TUTTO il contenuto
3. Sul server, esegui:

```bash
cd /home/users/fantasting/www
nano install.sh
```

4. Incolla tutto il contenuto
5. Salva: `Ctrl+X`, `Y`, `Enter`
6. Esegui:

```bash
chmod +x install.sh
./install.sh
```

## Lo script fa automaticamente:

✅ Clona il repository
✅ Installa Composer
✅ Modifica composer.json per PHP 7.4
✅ Installa tutte le dipendenze
✅ Configura .env
✅ Crea database
✅ Esegue migrazioni
✅ Ottimizza cache
✅ Imposta permessi

## Dopo l'installazione:

```bash
cd /home/users/fantasting/www/funtasting
php artisan serve --host=0.0.0.0 --port=8000
```

## Fine! 🎉

