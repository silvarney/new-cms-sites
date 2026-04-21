# ESTÁGIO 1: Build do front-end (Vue)
FROM node:18-alpine AS frontend

WORKDIR /app

COPY src/package*.json ./

RUN npm install

COPY src/ .

RUN npm run build

# ESTÁGIO 2: PHP com Nginx
FROM php:8.3-fpm-alpine

RUN apk add --no-cache nginx curl git unzip \
    libzip-dev libpng-dev libjpeg-turbo-dev freetype-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) pdo_mysql zip gd

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

COPY src/composer.json src/composer.lock* ./

RUN composer install --no-dev --optimize-autoloader --no-interaction --no-scripts

COPY src/ .

COPY --from=frontend /app/public/build /var/www/html/public/build

RUN php artisan package:discover --ansi && \
    php artisan config:cache && \
    php artisan route:cache && \
    php artisan view:cache

RUN rm -rf /etc/nginx/conf.d/default.conf
COPY docker/nginx/default.conf /etc/nginx/http.d/default.conf

RUN mkdir -p storage/framework/sessions \
    && mkdir -p storage/framework/views \
    && mkdir -p storage/framework/cache \
    && mkdir -p bootstrap/cache \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 775 storage bootstrap/cache

EXPOSE 80

CMD ["sh", "-c", "php-fpm -D && nginx -g 'daemon off;'"]