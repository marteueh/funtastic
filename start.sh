#!/bin/bash
PORT_NUM=${PORT:-8000}
php artisan serve --host=0.0.0.0 --port=$PORT_NUM

