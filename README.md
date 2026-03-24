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
    2. **Laravel用の設定**:**コンテナ起動後**、`src`ディレクトリ内に生成された`.env.example`の名前を`.env`に変更します(後述)。

    **重要**:ルートの`.env`と`src/.env`内の`DB_DATABASE`,`DB_USERNAME`,`DB_PASSWORD`の値は必ず一致させてください。

3. コンテナの起動と自動インストール\
以下のコマンドを実行すると、コンテナのビルドと同時に`entrypoint.sh`が走り、`src`内に`Laravel`が自動インストールされます。

```
$ docker compose up -d --build
```
4. Laravel用環境変数の設定\
コンテナ起動後、ホストの`src`ディレクトリ内に生成された`.env`ファイルの環境変数を設定します。\
ルートの`.env`に設定した`DB_DATABASE`、`DB_USERNAME`、`DB_PASSWORD`と同じ値を設定してください。

5. データベースのマイグレーション\
コンテナが起動し、インストールが完了したら（`$docker compose logs -f app` で進捗確認可能）、以下のコマンドでテーブルを作成します。

```
$ docker compose exec app php artisan migrate
```

## 4. 動作確認
* ・**Webサイト**:`http://localhost:8081`(環境によりポートは異なります)
* ・**MYSQL直接接続**:
    ```
    $ docker compose exec db mysql -u root -p
    ```
    パスワードは`.env`で指定した`DB_ROOT_PASSWORD`が必要です。

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

## 7. 更新履歴
* **2026-03-24**: `README.md`作成、クローンテストに成功。
* **2026-03-23**: リポジトリ作成