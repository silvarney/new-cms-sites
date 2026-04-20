# Dockerfile (na raiz do projeto)
FROM php:8.3-fpm-alpine

ENV APP_ENV=production

# Instala Node.js, NPM, Nginx e dependências do PHP
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

# Define diretório de trabalho
WORKDIR /var/www/html

# Copia arquivos de dependência primeiro (melhora cache)
COPY src/composer.json src/composer.lock* ./
COPY src/package*.json ./

# Instala dependências PHP e Node
RUN composer install --no-dev --optimize-autoloader --no-interaction --no-scripts

# Troque a linha do package:discover por:
RUN php artisan package:discover --ansi || cat storage/logs/laravel.log

# Copia o resto do código
COPY src/ .

# Build dos assets Vue
RUN npm run build

# Configuração do Nginx
RUN rm -rf /etc/nginx/conf.d/default.conf
COPY docker/nginx/default.conf /etc/nginx/http.d/default.conf

# Cria pastas necessárias e ajusta permissões
RUN mkdir -p storage/framework/sessions \
    && mkdir -p storage/framework/views \
    && mkdir -p storage/framework/cache \
    && mkdir -p bootstrap/cache \
    && chown -R www-data:www-data /var/www/html \
    && chmod -R 775 storage bootstrap/cache

# Health check
HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=3 \
    CMD curl -f http://localhost/up || exit 1

# Expõe porta 80
EXPOSE 80

# Script de entrada
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["php-fpm", "-D", "&&", "nginx", "-g", "daemon off;"]