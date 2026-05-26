#!/bin/bash
set -e

sed -i "s/DB_HOST=.*/DB_HOST=${DB_HOST:-db}/g" .env
sed -i "s/DB_DATABASE=.*/DB_DATABASE=${DB_DATABASE:-tailadmin}/g" .env
sed -i "s/DB_USERNAME=.*/DB_USERNAME=${DB_USERNAME:-root}/g" .env
sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=${DB_PASSWORD:-password}/g" .env

echo "Waiting for MySQL..."
while ! bash -c "cat /dev/null > /dev/tcp/${DB_HOST:-db}/3306" 2>/dev/null; do
    sleep 2
    echo "Still waiting..."
done
echo "MySQL ready!"

php artisan migrate --force
php artisan db:seed --force || echo "Seeding skipped or already done"
php artisan storage:link || true

php artisan serve --host=0.0.0.0 --port=8090
