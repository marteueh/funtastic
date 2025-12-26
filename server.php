<?php

$port = (int) ($_ENV['PORT'] ?? $_SERVER['PORT'] ?? 8000);
$host = '0.0.0.0';

$command = "php artisan serve --host=$host --port=$port";
passthru($command);

