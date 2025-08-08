FROM php:8.3-fpm

# Install PHP extensions and Supervisor
RUN apt-get update && apt-get install -y \
    git curl unzip zip libpq-dev libzip-dev libonig-dev supervisor \
    && docker-php-ext-install pdo pdo_pgsql zip mbstring

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy entrypoint and supervisor config
COPY docker/php/custom.ini /usr/local/etc/php/conf.d/custom.ini
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
COPY docker/php/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN chmod +x /usr/local/bin/entrypoint.sh

WORKDIR /var/www

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
