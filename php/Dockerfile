# --------------------------------------------------------
# 1. Node build stage — compile assets
# --------------------------------------------------------
FROM node:20-alpine AS node-build

WORKDIR /var/www

COPY package*.json ./
RUN npm ci

COPY vite.config.js ./
COPY resources ./resources
RUN npm run build


# --------------------------------------------------------
# 2. PHP build stage — install dependencies & setup app
# --------------------------------------------------------
FROM php:8.3-fpm

# Install system packages & PHP extensions
RUN apt-get update && apt-get install -y \
    git curl unzip zip \
    libpq-dev libzip-dev libicu-dev libxml2-dev libonig-dev \
    supervisor \
    && docker-php-ext-install \
    pdo pdo_mysql zip bcmath intl mbstring xml exif \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Redis extension
RUN pecl install redis && docker-php-ext-enable redis

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set working directory
WORKDIR /var/www

# copy composer files
COPY composer.json composer.lock ./

# install dependencies without scripts (artisan not yet available)
RUN composer install --no-dev --optimize-autoloader --no-interaction --prefer-dist --no-progress --ansi --no-scripts

# copy app source + artisan
COPY app ./app
COPY bootstrap ./bootstrap
COPY config ./config
COPY database ./database
COPY public ./public
COPY resources/views ./resources/views
COPY routes ./routes
COPY artisan ./
COPY storage ./storage
COPY .env.docker .env

# run composer scripts and dump autoload now artisan is available
RUN composer dump-autoload --optimize
RUN composer run-script post-autoload-dump

# Copy built frontend assets
COPY --from=node-build /var/www/public/build ./public/build

# Remove runtime cache/logs from image
RUN rm -rf storage/logs/* storage/framework/*


# Set permissions for Laravel
RUN mkdir -p storage/framework/cache storage/framework/sessions storage/framework/views storage/logs storage/app/public bootstrap/cache
RUN chown -R www-data:www-data storage bootstrap/cache && \
    chmod -R ug+rwx storage bootstrap/cache

# Copy entrypoint and supervisor config
COPY docker/php/entrypoint.sh /usr/local/bin/entrypoint.sh
COPY docker/php/supervisord.conf /etc/supervisor/conf.d/supervisord.conf
RUN chmod +x /usr/local/bin/entrypoint.sh

# Set entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]