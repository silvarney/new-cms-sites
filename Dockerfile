# Dockerfile corrigido
FROM php:8.3-fpm-alpine

# Instala dependências do sistema (mantém igual)
RUN apk add --no-cache \
    nginx \
    nodejs \
    npm \
    curl \
    git \
    unzip \
    libzip-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) pdo_mysql zip gd

# Instala Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# 1. Copia arquivos de dependência
COPY src/composer.json src/composer.lock* ./
COPY src/package*.json ./

# 2. Instala dependências
RUN composer install --no-dev --optimize-autoloader --no-interaction --no-scripts
RUN npm ci --production --no-audit --no-fund || npm install --production --no-audit --no-fund

# 3. Copia TODO o código (incluindo artisan)
COPY src/ .

# 4. Agora sim, executa comandos do Artisan
RUN php artisan package:discover --ansi
RUN php artisan config:cache
RUN php artisan route:cache
RUN php artisan view:cache

# 5. Build do Vue
RUN npm run build

# 6. Configuração do Nginx e permissões (mantém igual)
RUN rm -rf /etc/nginx/conf.d/default.conf
COPY docker/nginx/default.conf /etc/nginx/http.d/default.conf

RUN mkdir -p storage/framework/sessions \
    && mkdir -p storage/framework/views \
    && mkdir -p storage/framework/cache \
    && mkdir -p bootstrap/cache \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 775 storage bootstrap/cache

# Remove node_modules para reduzir tamanho
RUN rm -rf node_modules

EXPOSE 80

CMD ["sh", "-c", "php-fpm -D && nginx -g 'daemon off;'"]