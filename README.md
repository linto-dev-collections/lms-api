# LMS API

オンライン学習管理システム（LMS）の REST API バックエンドです。
レイヤードアーキテクチャを採用しています。

## 技術スタック

- Ruby 3.4 / Rails 8.1（API モード）
- PostgreSQL 17
- Docker Compose

### 主要ライブラリ

| カテゴリ | ライブラリ |
| --- | --- |
| 認証 | JWT (bcrypt) |
| 認可 | ActionPolicy |
| シリアライゼーション | Alba |
| 状態マシン | AASM |
| サービスオブジェクト | Dry::Initializer + Dry::Monads |
| 通知 | ActiveDelivery |
| 設定管理 | AnywayConfig |
| バリューオブジェクト | StoreModel |
| ページネーション | Pagy |
| メトリクス | Yabeda |
| API ドキュメント | rswag (OpenAPI 3.0.3) |

## アーキテクチャ

Rails の標準的な MVC に加え、以下のレイヤーを導入しています。

```txt
app/
├── adapters/         # 外部サービスアダプター
├── configs/          # AnywayConfig 設定クラス
├── controllers/      # API コントローラー
├── deliveries/       # ActiveDelivery 通知配信
├── forms/            # フォームオブジェクト（バリデーション）
├── middleware/       # Rack ミドルウェア
├── models/           # ActiveRecord モデル（AASM 含む）
├── notifiers/        # 通知ドライバー
├── policies/         # ActionPolicy 認可ポリシー
├── serializers/      # Alba シリアライザー
└── services/         # サービスオブジェクト（Dry::Monads）
```

## セットアップ

```bash
# コンテナの起動
docker compose up -d

# データベースの作成・マイグレーション
docker compose exec web rails db:create db:migrate

# テスト用データベースの準備
docker compose exec -e RAILS_ENV=test web rails db:create db:migrate
```

## テスト

```bash
# 全テスト実行
docker compose exec -e RAILS_ENV=test web bundle exec rspec

# RuboCop
docker compose exec web bundle exec rubocop
```

## API ドキュメント

OpenAPI 3.0.3 仕様に基づいた API ドキュメントを Swagger UI で提供しています。

```bash
# OpenAPI スキーマ生成
docker compose exec -e RAILS_ENV=test web bundle exec rake rswag:specs:swaggerize
```

サーバー起動後、ブラウザで <http://localhost:3000/api-docs> にアクセスしてください。
