<?php

// Cambia alla directory del progetto
chdir(__DIR__);

// Leggi PORT da variabili d'ambiente Railway
$port = (int) (getenv('PORT') ?: 8000);
$host = '0.0.0.0';

// Verifica che la porta sia valida
if ($port <= 0 || $port > 65535) {
    $port = 8000;
}

$command = "php artisan serve --host=$host --port=$port 2>&1";
passthru($command);

