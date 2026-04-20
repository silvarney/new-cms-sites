#!/bin/sh
set -e

# Detecta se precisa instalar dependências
if [ ! -f vendor/autoload.php ]; then
    echo "📦 Instalando dependências PHP..."
    composer install --no-interaction
fi

if [ ! -d node_modules ]; then
    echo "📦 Instalando dependências Node..."
    npm install --no-audit --no-fund
fi

if [ ! -d public/build ]; then
    echo "🔨 Buildando assets..."
    npm run build
fi

# Garante permissões corretas a cada inicialização
chown -R www-data:www-data storage bootstrap/cache
chmod -R 775 storage bootstrap/cache

# Executa o comando principal
exec "$@"