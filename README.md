# Subir os containers
docker-compose up --build -d

# Acessa o terminal do container app
docker exec -it laravel_app_development bash

# Dentro do container, execute:
php artisan key:generate
php artisan migrate
php artisan storage:link
exit

# Se precisar limpar
php artisan cache:clear
php artisan view:clear
