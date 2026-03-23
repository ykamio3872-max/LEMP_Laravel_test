#!/bin/bash

# srcディレクトリが空、かつ laravel が未インストールの場合のみ実行
if [ ! -f "artisan" ]; then
    composer create-project --prefer-dist "laravel/laravel=8.*" .
    # 必要に応じて権限を変更
    chmod -R 777 storage bootstrap/cache
fi

# Docker本来のプロセス（php-fpm）を起動
exec "$@"