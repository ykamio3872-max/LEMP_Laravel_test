#!/bin/bash

# 1. ルートの .env 作成（未作成の場合のみ）
if [ ! -f .env ]; then
    echo "Creating root .env from .env.example..."
    cp .env.example .env
fi

# 2. コンテナの起動
echo "Starting Docker containers..."
docker compose up -d

# 3. Laravelのインストール待ち
# src/artisan が出現するまでループで待機します（最大60秒）
# --- 修正版：3. Laravelのインストール完了（vendor含む）を待機 ---
echo "Waiting for Laravel and dependencies (vendor) to be fully installed..."
echo "This takes time on some environments. Please wait (Max 10 mins)..."

seconds=0
# 待機条件を vendor/autoload.php の存在に変更
while [ ! -f src/vendor/autoload.php ] && [ $seconds -lt 600 ]; do
    sleep 5
    seconds=$((seconds + 5))
    echo -n "Installing... (${seconds}s) "

    # 1分（60秒）ごとに改行して見やすくする
    if [ $((seconds % 60)) -eq 0 ]; then echo ""; fi
done
echo -e "\nLaravel dependencies detected!"

if [ ! -f src/vendor/autoload.php ]; then
    echo "Error: Installation timed out. 'vendor/autoload.php' not found."
    echo "Try running: docker compose logs app"
    exit 1
fi

# flysystemのインストール
echo "Installing S3 adapter (Flysystem AWS S3)..."
docker compose exec -T app composer require league/flysystem-aws-s3-v3:"~1.0"

# 4. 検証用ファイルのデプロイ
echo "Deploying example files to 'src'..."
cp EXAMPLES/web.php src/routes/web.php
cp EXAMPLES/welcome.blade.php src/resources/views/welcome.blade.php

# 5. Laravel側の .env 作成と AWS 設定の追記
echo "Configuring Laravel .env with AWS settings..."
cp src/.env.example src/.env

# --- 6. Laravel側の .env 作成と AWS 設定の追記 ---
echo "Configuring Laravel .env with AWS settings..."
cp src/.env.example src/.env

# 直接書き込まず、EXAMPLESにあるテンプレートを末尾に結合する
if [ -f EXAMPLES/.env.laravel.example ]; then
    cat EXAMPLES/.env.laravel.example >> src/.env
    echo "AWS settings appended from template."
else
    echo "Warning: EXAMPLES/.env.laravel.example not found."
fi

# 6. Laravelの初期化コマンド実行
echo "Running Laravel initialization..."
docker compose exec app php artisan key:generate
docker compose exec app php artisan migrate:fresh

# 7. LocalStackのバケット作成（念のため）
echo "Creating S3 bucket in LocalStack..."
docker compose exec aws awslocal s3 mb s3://my-test-bucket
docker compose exec aws awslocal s3api put-bucket-acl --bucket my-test-bucket --acl public-read

echo "--------------------------------------------------"
echo "Setup complete! Ready to develop."
echo "Access: http://localhost:8081"
echo "--------------------------------------------------"