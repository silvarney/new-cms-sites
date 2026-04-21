# ESTÁGIO 1: Build do front-end (Vue)
FROM node:18-alpine AS frontend

WORKDIR /app

# Copia arquivos de dependência do Node
COPY src/package*.json ./

# Instala dependências e faz o build
RUN npm ci --no-audit --no-fund && npm run build

# ESTÁGIO 2: PHP com Nginx
FROM php:8.3-fpm-alpine

# Instala Nginx e extensões do PHP
RUN apk add --no-cache nginx curl git unzip \
    libzip-dev libpng-dev libjpeg-turbo-dev freetype-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) pdo_mysql zip gd

# Instala Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# Copia arquivos de dependência PHP
COPY src/composer.json src/composer.lock* ./

# Instala dependências PHP
RUN composer install --no-dev --optimize-autoloader --no-interaction --no-scripts

# Copia o resto do código PHP
COPY src/ .

# Copia os assets buildados do estágio frontend
COPY --from=frontend /app/public/build /var/www/html/public/build

# Executa scripts do Laravel
RUN php artisan package:discover --ansi \
    && php artisan config:cache \
    && php artisan route:cache \
    && php artisan view:cache

# Configura Nginx
RUN rm -rf /etc/nginx/conf.d/default.conf
COPY docker/nginx/default.conf /etc/nginx/http.d/default.conf

# Prepara pastas
RUN mkdir -p storage/framework/sessions \
    && mkdir -p storage/framework/views \
    && mkdir -p storage/framework/cache \
    && mkdir -p bootstrap/cache \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 775 storage bootstrap/cache

EXPOSE 80

CMD ["sh", "-c", "php-fpm -D && nginx -g 'daemon off;'"]