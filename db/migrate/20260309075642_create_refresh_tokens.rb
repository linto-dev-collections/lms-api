class CreateRefreshTokens < ActiveRecord::Migration[8.1]
  def change
    create_table :refresh_tokens do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.string :token_digest, null: false, limit: 255
      t.string :jti, null: false, limit: 255
      t.timestamptz :expires_at, null: false
      t.timestamptz :revoked_at

      t.timestamptz :created_at, null: false
    end

    add_index :refresh_tokens, :token_digest, unique: true
    add_index :refresh_tokens, :jti, unique: true
    add_index :refresh_tokens, :user_id,
              where: "revoked_at IS NULL",
              name: "index_refresh_tokens_active"
  end
end
