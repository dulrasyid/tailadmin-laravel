#!/bin/sh
set -e

mkdir -p bootstrap/cache \
    storage/framework/cache \
    storage/framework/sessions \
    storage/framework/views

chown -R www-data:www-data bootstrap storage || true
chmod -R ug+rwx bootstrap storage || true

npm install --legacy-peer-deps --no-audit --progress=false
npm run build

composer install --optimize-autoloader --no-dev

cp .env.example .env || true
php artisan key:generate

