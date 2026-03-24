#! bin/bash
# artisan ファイルが存在しない場合のみインストールを実行
if [ ! -f "/var/www/html/artisan" ]; then
    echo "Artisan not found. Installing Laravel..."
    composer create-project --prefer-dist "laravel/laravel=8.*" .
    chmod -R 777 storage bootstrap/cache
fi

# Docker本来のプロセス（php-fpm）を起動
exec "$@"