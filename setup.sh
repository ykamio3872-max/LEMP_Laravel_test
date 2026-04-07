#!/bin/bash

# 1. ルートの .env 作成
if [ ! -f .env ]; then
    cp .env.example .env
fi

# 2. コンテナ起動
docker compose up -d 

# 3. Laravelインストール待機
echo "Waiting for Laravel dependencies..."
seconds=0
while [ ! -f src/vendor/autoload.php ] && [ $seconds -lt 600 ]; do
    sleep 5
    seconds=$((seconds + 5))
    echo -n "."
done
echo -e "\nLaravel detected!"

# 4. S3ライブラリ追加インストール
echo "Installing S3 adapter..."
docker compose exec -T app composer require league/flysystem-aws-s3-v3:"~1.0"

# 5. ファイルデプロイ[cite: 12]
cp EXAMPLES/web.php src/routes/web.php
cp EXAMPLES/welcome.blade.php src/resources/views/welcome.blade.php

# --- 追加手順 5.5: マイグレーションファイルの自動生成 ---
echo "Generating migration for images table..."
MIGRATION_FILE="src/database/migrations/$(date +%Y_%m_%d_%H%M%S)_create_images_table.php"
cat <<'EOF' > "$MIGRATION_FILE"
<?php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    public function up()
    {
        Schema::create('images', function (Blueprint $table) {
            $table->id();
            $table->string('file_name');
            $table->string('s3_path');
            $table->timestamps();
        });
    }
    public function down() { Schema::dropIfExists('images'); }
};
EOF

# 6. 環境設定の修正[cite: 12]
cp src/.env.example src/.env
sed -i 's/DB_HOST=127.0.0.1/DB_HOST=db/g' src/.env
sed -i 's/DB_DATABASE=laravel/DB_DATABASE=laravel_db/g' src/.env
sed -i 's/DB_USERNAME=root/DB_USERNAME=user/g' src/.env
sed -i 's/DB_PASSWORD=/DB_PASSWORD=password/g' src/.env

if [ -f EXAMPLES/.env.laravel.example ]; then
    cat EXAMPLES/.env.laravel.example >> src/.env
fi

# 7. 初期化[cite: 12]
echo "Waiting 20 seconds for DB to wake up..."
sleep 20
docker compose exec -T app php artisan key:generate
# ここで上記で作ったファイルが実行され、imagesテーブルが作られます
docker compose exec -T app php artisan migrate:fresh --force

# 8. S3バケット作成[cite: 12]
docker compose exec -T aws awslocal s3 mb s3://my-test-bucket