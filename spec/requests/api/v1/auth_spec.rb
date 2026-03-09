# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Api::V1::Auth", type: :request do
  path "/api/v1/auth/register" do
    post "ユーザー登録" do
      tags "Auth"
      consumes "application/json"
      produces "application/json"

      parameter name: :params, in: :body, schema: {
        "$ref" => "#/components/schemas/register_params"
      }

      response "201", "登録成功" do
        schema type: :object,
               properties: {
                 user: { "$ref" => "#/components/schemas/user" },
                 access_token: { type: :string },
                 refresh_token: { type: :string },
                 token_type: { type: :string },
                 expires_in: { type: :integer }
               },
               required: %w[user access_token refresh_token]

        let(:params) do
          {
            user: {
              email: "test@example.com",
              name: "テストユーザー",
              password: "password123",
              password_confirmation: "password123"
            }
          }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["access_token"]).to be_present
          expect(data["refresh_token"]).to be_present
          expect(data["user"]["email"]).to eq("test@example.com")
        end
      end

      response "422", "バリデーションエラー" do
        schema "$ref" => "#/components/schemas/error_response"

        let(:params) { { user: { email: "" } } }

        run_test!
      end
    end
  end

  path "/api/v1/auth/login" do
    post "ログイン" do
      tags "Auth"
      consumes "application/json"
      produces "application/json"

      parameter name: :params, in: :body, schema: {
        "$ref" => "#/components/schemas/login_params"
      }

      response "200", "ログイン成功" do
        schema type: :object,
               properties: {
                 user: { "$ref" => "#/components/schemas/user" },
                 access_token: { type: :string },
                 refresh_token: { type: :string },
                 token_type: { type: :string },
                 expires_in: { type: :integer }
               },
               required: %w[user access_token refresh_token]

        let(:user) { create(:user, email: "test@example.com", password: "password123") }
        let(:params) { { auth: { email: user.email, password: "password123" } } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["access_token"]).to be_present
        end
      end

      response "401", "認証失敗" do
        schema "$ref" => "#/components/schemas/error_response"

        let(:params) { { auth: { email: "wrong@example.com", password: "wrong" } } }

        run_test!
      end
    end
  end

  path "/api/v1/auth/logout" do
    delete "ログアウト" do
      tags "Auth"
      consumes "application/json"
      security [ bearer_auth: [] ]

      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          refresh_token: { type: :string }
        }
      }, required: false

      response "204", "ログアウト成功" do
        let(:user) { create(:user) }
        let(:tokens) { Auth::GenerateTokensService.call(user).value! }
        let(:Authorization) { "Bearer #{tokens[:access_token]}" }
        let(:params) { { refresh_token: tokens[:refresh_token] } }

        run_test!
      end
    end
  end

  path "/api/v1/auth/refresh" do
    post "トークンリフレッシュ" do
      tags "Auth"
      consumes "application/json"
      produces "application/json"

      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          refresh_token: { type: :string }
        },
        required: %w[refresh_token]
      }

      response "200", "リフレッシュ成功" do
        schema "$ref" => "#/components/schemas/auth_tokens"

        let(:user) { create(:user) }
        let(:params) do
          result = Auth::GenerateTokensService.call(user)
          { refresh_token: result.value![:refresh_token] }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["access_token"]).to be_present
          expect(data["refresh_token"]).to be_present

          # トークン再利用検知テスト
          post "/api/v1/auth/refresh", params: params, as: :json
          expect(self.response).to have_http_status(:unauthorized)
        end
      end

      response "401", "無効なリフレッシュトークン" do
        schema "$ref" => "#/components/schemas/error_response"

        let(:params) { { refresh_token: "invalid_token" } }

        run_test!
      end
    end
  end

  path "/api/v1/users/me" do
    get "認証必須エンドポイント" do
      tags "Auth"
      produces "application/json"

      response "401", "未認証" do
        schema "$ref" => "#/components/schemas/error_response"

        run_test!
      end
    end
  end
end
