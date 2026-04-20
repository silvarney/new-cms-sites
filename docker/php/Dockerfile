# docker/php/Dockerfile
FROM php:8.3-fpm AS base

# Configurações base (comuns a todos ambientes)
RUN apt-get update && apt-get install -y \
    git \
    curl \
    zip \
    unzip \
    libzip-dev \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    nodejs \
    npm \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd zip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Instala Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# ============================================
# ESTÁGIO DE DESENVOLVIMENTO
# ============================================
FROM base AS development

# Configurações para desenvolvimento
ENV APP_ENV=local
ENV APP_DEBUG=true

# Instala XDebug (só em desenvolvimento)
RUN pecl install xdebug \
    && docker-php-ext-enable xdebug

# Cria script de entrada que instala dependências dinamicamente
COPY docker/php/entrypoint-dev.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Garante permissões corretas
RUN mkdir -p storage bootstrap/cache \
    && chown -R www-data:www-data . \
    && chmod -R 775 storage bootstrap/cache

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["php-fpm"]

# ============================================
# ESTÁGIO DE PRODUÇÃO
# ============================================
FROM base AS production

# Configurações para produção
ENV APP_ENV=production
ENV APP_DEBUG=false

# Copia apenas o necessário (otimizado)
COPY src/ .

# Instala dependências em modo produção
RUN composer install --no-dev --optimize-autoloader --no-interaction \
    && npm install --production --no-audit --no-fund \
    && npm run build

# Limpa arquivos desnecessários
RUN rm -rf node_modules \
    && apt-get purge -y nodejs npm \
    && apt-get autoremove -y

# Ajusta permissões
RUN mkdir -p storage bootstrap/cache \
    && chown -R www-data:www-data . \
    && chmod -R 775 storage bootstrap/cache \
    && chmod -R 775 bootstrap/cache

CMD ["php-fpm"]