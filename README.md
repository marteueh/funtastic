# FUNTASTING - Marketplace Esperienziale

Marketplace per la prenotazione di esperienze turistiche, enogastronomiche e sportive nelle Marche.

## 🚀 Tecnologie

- **Backend:** Laravel 12
- **Frontend:** Blade Templates + Tailwind CSS
- **Database:** MySQL/PostgreSQL
- **Autenticazione:** Laravel Sanctum

## 📋 Requisiti

- PHP 8.2+
- Composer
- Node.js 20+ e npm
- MySQL/PostgreSQL

## 🛠️ Installazione Locale

1. **Clona il repository**
   ```bash
   git clone <repository-url>
   cd funtasting
   ```

2. **Installa le dipendenze**
   ```bash
   composer install
   npm install
   ```

3. **Configura l'ambiente**
   ```bash
   cp .env.example .env
   php artisan key:generate
   ```

4. **Configura il database nel file `.env`**
   ```env
   DB_CONNECTION=mysql
   DB_HOST=127.0.0.1
   DB_PORT=3306
   DB_DATABASE=funtasting
   DB_USERNAME=root
   DB_PASSWORD=
   ```

5. **Esegui le migrazioni**
   ```bash
   php artisan migrate
   php artisan db:seed
   ```

6. **Compila gli asset**
   ```bash
   npm run build
   ```

7. **Avvia il server**
   ```bash
   php artisan serve
   ```

8. **Apri nel browser**
   ```
   http://localhost:8000
   ```

## 👥 Utenti di Test

Dopo aver eseguito i seeder, puoi accedere con:

- **Admin:** `admin@funtasting.it` / `password`
- **Vendor:** `vendor1@funtasting.it` / `password`
- **Reseller:** `reseller1@funtasting.it` / `password`
- **Customer:** `customer@funtasting.it` / `password`

## 📦 Deploy

Vedi il file [DEPLOY.md](DEPLOY.md) per le istruzioni complete di deploy.

### Deploy Rapido con Railway

1. Crea un account su [railway.app](https://railway.app)
2. Connetti il repository GitHub
3. Aggiungi un database MySQL
4. Configura le variabili d'ambiente
5. Railway eseguirà automaticamente il deploy

## 📁 Struttura Progetto

```
funtasting/
├── app/
│   ├── Http/
│   │   ├── Controllers/     # Controller dell'applicazione
│   │   └── Middleware/       # Middleware personalizzati
│   └── Models/               # Modelli Eloquent
├── database/
│   ├── migrations/           # Migrazioni database
│   └── seeders/             # Seeder per dati iniziali
├── resources/
│   ├── views/               # Viste Blade
│   ├── css/                 # File CSS
│   └── js/                  # File JavaScript
├── routes/
│   └── web.php              # Route web
└── public/                   # File pubblici
```

## 🔐 Ruoli Utente

- **Admin:** Gestione completa della piattaforma
- **Vendor:** Creazione e gestione esperienze
- **Reseller:** Vendita esperienze ai propri clienti
- **Customer:** Prenotazione esperienze

## 📝 Funzionalità

- ✅ Ricerca avanzata esperienze
- ✅ Sistema di prenotazione
- ✅ Dashboard multi-ruolo
- ✅ Gestione esperienze (CRUD)
- ✅ Sistema commissioni per reseller
- ✅ Autenticazione e autorizzazione

## 🐛 Troubleshooting

### Problemi con Vite
```bash
npm install
npm run build
```

### Problemi con permessi storage
```bash
chmod -R 775 storage bootstrap/cache
```

### Clear cache
```bash
php artisan config:clear
php artisan route:clear
php artisan view:clear
php artisan cache:clear
```

## 📄 Licenza

Proprietario - Tutti i diritti riservati

## 👨‍💻 Sviluppo

Per lo sviluppo con hot-reload:
```bash
npm run dev
php artisan serve
```
