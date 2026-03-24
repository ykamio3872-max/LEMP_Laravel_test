#!/bin/bash

# artisan ファイルが存在しない場合のみインストールを実行
if [ ! -f "/var/www/html/artisan" ]; then
    echo "Artisan not found. Installing Laravel..."
    # 既存の .gitkeep 等があっても、一度カレントディレクトリに展開するために --force などを検討するか、
    # または一度 composer でプロジェクトを作成してから中身を移動させる処理が一般的です。
    # ここでは最もシンプルな「中身を空にしてから作成」の形を例示します。
    
    composer create-project --prefer-dist "laravel/laravel=8.*" . --remove-vcs
    
    chmod -R 777 storage bootstrap/cache
    echo "Laravel installation finished."
fi

# Docker本来のプロセス（php-fpm）を起動
exec "$@"