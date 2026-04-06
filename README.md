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
`.env.example`に以下の値を入力し、ファイル名を`.env`に変更してください。

```
DB_DATABASE=laravel_db
DB_USER=user 
DB_PASSWORD=password 
DB_ROOT_PASSWORD=password

AWS_ACCESS_KEY_ID=test
AWS_SECRET_ACCESS_KEY=test 
AWS_DEFAULT_REGION=ap-northeast-1
AWS_USE_PATH_STYLE_ENDPOINT=true
AWS_ENDPOINT=http://aws:4566
AWS_LOCAL_ENDPOINT=http://aws:4566

LOCALSTACK_SERVICES=s3,rds

AWS_URL=http://localhost:4566/my-test-bucket
```

3. コンテナの起動と自動インストール\
ディレクトリのルートで以下のコマンドを実行してください。

```bash
$ chmod +x setup.sh
$ ./setup.sh
```
powershellを使用する場合は、以下のコマンドを実行してください。

```powershell
$ sh setup.sh
```

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
* **2026-04-03**: setup.shの実装と自動化に成功
* **2026-04-03**: LocalStackのバージョン固定/画像アップロード・削除機能実装
* **2026-03-25**: Localstack+AWS環境を試験的に実装。
* **2026-03-24**: `README.md`作成、クローンテストに成功。
* **2026-03-23**: リポジトリ作成