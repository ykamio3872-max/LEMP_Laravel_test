#!/bin/bash

# 1. 判定用の変数を作成（ls -A の結果から .gitkeep を除外）
# -F をつけることでディレクトリ等の判定を避け、1行ずつ出力させて確実にカウントします
FILES=$(ls -A /var/www/html | grep -v ".gitkeep")

# 2. 変数が空（= .gitkeep 以外のファイルが存在しない）場合に実行
# [ ] の前後には必ず半角スペースを入れてください
if [ -z "$FILES" ]; then
    echo "Starting Laravel installation..."
    composer create-project --prefer-dist "laravel/laravel=8.*" .
    
    # 権限変更
    chmod -R 777 storage bootstrap/cache
    echo "Installation completed."
else
    echo "Source directory is not empty. Skipping installation."
fi

# Docker本来のプロセス（php-fpm）を起動
exec "$@"