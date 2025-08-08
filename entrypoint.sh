#!/bin/bash

set -e

echo "Waiting for PostgreSQL and Redis..."

until pg_isready -h "$DB_HOST" -p "$DB_PORT" -U "$DB_USERNAME" > /dev/null 2>&1; do
  sleep 1
done

until redis-cli -h "$REDIS_HOST" ping | grep -q PONG; do
  sleep 1
done

# Generate .env if missing
if [ ! -f ".env" ]; then
  echo "Generating .env..."
  cp .env.example .env 2>/dev/null || touch .env

  cat <<EOF > .env
APP_NAME=Laravel
APP_ENV=production
APP_KEY=
APP_DEBUG=false
APP_URL=http://localhost

LOG_CHANNEL=stack

DB_CONNECTION=pgsql
DB_HOST=$DB_HOST
DB_PORT=$DB_PORT
DB_DATABASE=$DB_DATABASE
DB_USERNAME=$DB_USERNAME
DB_PASSWORD=$DB_PASSWORD

BROADCAST_DRIVER=log
CACHE_DRIVER=redis
QUEUE_CONNECTION=redis
SESSION_DRIVER=redis
REDIS_HOST=$REDIS_HOST
EOF
fi

# Generate app key if not set
if ! grep -q "^APP_KEY=" .env || grep -q "APP_KEY=$" .env; then
  echo "Generating APP_KEY..."
  php artisan key:generate --force
fi

# Laravel setup
echo "Running Laravel setup..."
composer install --no-dev --optimize-autoloader
php artisan config:clear
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan migrate --force

# Automate public/storage symlink once
echo "Checking storage symlink..."
if [ ! -L "public/storage" ]; then
  echo "Creating storage symlink..."
  php artisan storage:link
else
  echo "Storage symlink already exists, skipping..."
fi

# Set permissions
chown -R www-data:www-data storage bootstrap/cache

# Start Supervisor
echo "Starting Supervisor..."
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf
