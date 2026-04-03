# LEMP Stack with Laravel(docker environment)
## １．プロジェクト概要
Dockerを使用して構築したLEMP環境（Nginx, MySQL, PHP-FPM）上で、Laravel 8.x を動作させるためのテストプロジェクトです。
リポジトリをクローンするだけで、コマンド一つでLaravelの初期セットアップまで完了するように設計されています。

## ２．ディレクトリ構成
```
.
├── docker/              # 各コンテナの設定ファイル（Dockerfile等）
├── docker-compose.yml   # サービス全体の定義
├── .env.example         # Docker環境用設定（DB名・パスワード等）
├── src/                 # Laravelプロジェクト本体
│   └── .env             # Laravelアプリ用設定（DB接続先・キー等）
└── README.md
```

## ３．セットアップ手順
以下の手順を実行することで、ローカル環境にLaravelを立ち上げます。

1. リポジトリのクローン
```
$ git clone https://www.github.com/ykamio3872-max/LEMP_Laravel_test.git
$ cd LEMP_Laravel_test
```
2. 環境変数の設定\
本プロジェクトには、ルート直下とsrc内の2箇所に`.env`が必要です。

    1. **Docker用の設定**: ルート直下の`.env.example`を`.env`にコピーし、必要に応じてDB名などを編集します。
    2. **Laravel用の設定**:**コンテナ起動後**、`src`ディレクトリ内に生成された`.env`の環境変数値を変更します。
       
       |項目(key)|値(value)|
       | :--- | :--- |
       |DB_HOST|=db|
       |DB_DATABASE|=(ルートの`.env`と同じ値)|
       |DB_USER|=(ルートの`.env`と同じ値)|
       |DB_PASSWORD|=(ルートの`.rnv`と同じ値)|

    **重要**:ルートの`.env`と`src/.env`内の`DB_DATABASE`,`DB_USERNAME`,`DB_PASSWORD`の値は必ず一致させてください。

3. コンテナの起動と自動インストール\
以下のコマンドを実行すると、コンテナのビルドと同時に`entrypoint.sh`が走り、`src`内に`Laravel`が自動インストールされます。

```
$ docker compose up -d --build
```
4. Laravel用環境変数の設定\
コンテナ起動後、ホストの`src`ディレクトリ内に生成された`.env`ファイルの環境変数を設定します。\
ルートの`.env`に設定した`DB_DATABASE`、`DB_USERNAME`、`DB_PASSWORD`と同じ値を設定してください。\
(追記)Localstack+AWSの導入に伴い、以下の値も設定をしてください。ない項目は手動で入力します。

```
AWS_ACCESS_KEY_ID=test
AWS_SECRET_ACCESS_KEY=test
AWS_DEFAULT_REGION=ap-northeast-1
AWS_BUCKET=my-test-bucket
AWS_ENDPOINT=http://aws:4566
AWS_USE_PATH_STYLE_ENDPOINT=true
AWS_URL=http://localhost:4566/my-test-bucket
```

5. データベースのマイグレーション\
コンテナが起動し、インストールが完了したら（`$docker compose logs -f app` で進捗確認可能）、以下のコマンドでテーブルを作成します。

```
$ docker compose exec app php artisan migrate
```

6. ライブラリのインストール（重要：バージョン固定）\
Laravel 8の場合、最新版を導入すると`ReadInterface not found`エラーが出るため、必ずバージョン**1.x**を指定する。

```
# vendorがない場合
docker-compose exec app composer install

# S3用アダプターの追加
docker-compose exec app composer require league/flysystem-aws-s3-v3:"~1.0"
```

7. 権限の修正\
`StreamHandler`エラー（ログ書き込み失敗）を防ぐため実行

```
docker-compose exec app chmod -R 777 storage bootstrap/cache
```

8. Localstackの初期化\
現状では、コンテナ起動のたびにバケットを手動作成する必要がある(自動化予定)。

```
# バケット作成
docker-compose exec app curl -X PUT http://aws:4566/my-test-bucket

# 作成確認(XMLが返ればOK)
docker-compose exec app curl http://aws:4566/my-test-bucket
```

9. 動作確認用ページの編集\
ルートディレクトリにある`web.php.example`のコードを、`src/routes/web.php`にコピーしてください。\
同様に、`welcome.blade.php.example`のコードを、`src/resources/views/welcome.blade.php`にコピーしてください。

## 4. 動作確認
* **Webサイト**:`http://localhost:8081`(環境によりポートは異なります)
* **MYSQL直接接続**:
    ```
    $ docker compose exec db mysql -u root -p
    ```
    パスワードは`.env`で指定した`DB_ROOT_PASSWORD`が必要です。
* **AWS動作確認**: http://localhost:8081/s3-upload-test \
    バケット作成に成功しているとjson形式で情報が表示されます。

## 5. トラブルシューティング・注意事項

* **Q. `src`が空ではないというエラーでインストールが止まる**\
    Laravelの自動インストールは、`src`内に`artisan`ファイルがない場合のみ実行されます。`.gitkeep`などの隠しファイルが存在しても一時ディレクトリを経由してインストールされるよう `entrypoint.sh`で制御していますが、失敗する場合は一度`src`内を空にして再試行してください。

* **Q. データベース接続エラー (Unknown database)**\
    ルートの `.env`と`src/.env`のDB名が食い違っている可能性があります。両者を修正した後、以下のコマンドでボリュームをリセットして再起動してください。
    ```
    $ docker compose down -v
    $ docker compose up -d
    ```
* **Q. `vendor/autoload.php`がないというエラーが出る**\
    `composer install`が完了していない可能性があります。`$ docker compose exec app composer install`を手動で実行してください。

## 6. 技術スタック
* ・**Infrastructure**: Docker Compose
* ・**Server**: Nginx(Web), PHP 8.1-fpm(App), MySQL 8.0(DB)
* ・**Framework**: Laravel 8.x
* ・**LocalStack**: LocalStack 3.4.0

## 7. 更新履歴
* **2026-04-03**: LocalStackのバージョン固定/画像アップロード・削除機能実装
* **2026-03-25**: Localstack+AWS環境を試験的に実装。
* **2026-03-24**: `README.md`作成、クローンテストに成功。
* **2026-03-23**: リポジトリ作成