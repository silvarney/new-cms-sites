#!/bin/sh
set -e

# Aguarda o banco de dados ficar disponível
if [ ! -z "$DB_HOST" ]; then
    echo "Aguardando banco de dados $DB_HOST..."
    while ! nc -z $DB_HOST $DB_PORT; do
        sleep 1
    done
    echo "Banco de dados disponível!"
fi

# Executa migrações em produção (opcional)
if [ "$APP_ENV" = "production" ]; then
    php artisan migrate --force
fi

# Inicia PHP-FPM e Nginx
php-fpm -D
nginx -g "daemon off;"