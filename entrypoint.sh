#!/bin/bash
set -e

# --- Step 3: Ensure storage symlink exists ---
if [ ! -L "public/storage" ]; then
  echo "Creating storage symlink..."
  php artisan storage:link
else
  echo "Storage symlink already exists."
fi

# --- Step 4: (Optional) Enable maintenance mode before migration ---
# echo "Putting application into maintenance mode..."
# php artisan down

# --- Step 5: Run migrations safely ---
# echo "Running migrations..."
# php artisan migrate 

# --- Step 6: (Optional) Bring app out of maintenance mode ---
# echo "Bringing application out of maintenance mode..."
# php artisan up

# --- Step 7: Cache config, routes, and views ---
echo "Caching configuration..."
php artisan optimize

# --- Step 8: Optimize Filament icons (if Filament installed) ---
php artisan filament:optimize || echo "Filament optimization skipped."

# --- Step 9: Restart queue workers ---
echo "Restarting queue workers..."
php artisan queue:restart || echo "Queue restart failed or not configured."

# --- Step 10: Start Supervisor as main process ---
echo "Starting Supervisor..."
exec /usr/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf