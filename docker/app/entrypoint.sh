#!/bin/bash

# srcコンテナに.gitkeepのみ存在するときに実行
if [ -z "$(ls -A /var/www/html | grep -v .gitkeep)"]; then
    composer create-project --prefer-dist "laravel/laravel=8.*" .
    # 必要に応じて権限を変更
    chmod -R 777 storage bootstrap/cache
fi

# Docker本来のプロセス（php-fpm）を起動
exec "$@"