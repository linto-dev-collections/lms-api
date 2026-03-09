# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Api::V1::Users", type: :request do
  path "/api/v1/users/me" do
    get "自分のプロフィール取得" do
      tags "Users"
      produces "application/json"
      security [ bearer_auth: [] ]

      response "200", "プロフィール取得成功" do
        schema "$ref" => "#/components/schemas/user"

        let(:user) { create(:user) }
        let(:Authorization) { auth_headers_for(user)["Authorization"] }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["email"]).to eq(user.email)
        end
      end
    end

    patch "自分のプロフィール更新" do
      tags "Users"
      consumes "application/json"
      produces "application/json"
      security [ bearer_auth: [] ]

      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string }
        }
      }

      response "200", "更新成功" do
        schema "$ref" => "#/components/schemas/user"

        let(:user) { create(:user) }
        let(:Authorization) { auth_headers_for(user)["Authorization"] }
        let(:params) { { name: "新しい名前" } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["name"]).to eq("新しい名前")
        end
      end
    end
  end

  path "/api/v1/users" do
    get "ユーザー一覧（管理者のみ）" do
      tags "Users"
      produces "application/json"
      security [ bearer_auth: [] ]

      parameter name: :page, in: :query, type: :integer, required: false
      parameter name: :items, in: :query, type: :integer, required: false

      response "200", "ユーザー一覧取得成功" do
        schema type: :object,
               properties: {
                 users: { type: :array, items: { "$ref" => "#/components/schemas/user" } },
                 meta: { "$ref" => "#/components/schemas/pagination_meta" }
               },
               required: %w[users meta]

        let(:admin) { create(:user, :admin) }
        let(:Authorization) { auth_headers_for(admin)["Authorization"] }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key("users")
        end
      end

      response "403", "権限なし" do
        schema "$ref" => "#/components/schemas/error_response"

        let(:student) { create(:user, :student) }
        let(:Authorization) { auth_headers_for(student)["Authorization"] }

        run_test!
      end
    end
  end

  path "/api/v1/users/{id}" do
    parameter name: :id, in: :path, type: :integer, required: true

    get "ユーザー詳細（管理者のみ）" do
      tags "Users"
      produces "application/json"
      security [ bearer_auth: [] ]

      response "200", "ユーザー詳細取得成功" do
        schema "$ref" => "#/components/schemas/user"

        let(:admin) { create(:user, :admin) }
        let(:Authorization) { auth_headers_for(admin)["Authorization"] }
        let(:target_user) { create(:user, :student) }
        let(:id) { target_user.id }

        run_test!
      end

      response "403", "権限なし" do
        schema "$ref" => "#/components/schemas/error_response"

        let(:student) { create(:user, :student) }
        let(:Authorization) { auth_headers_for(student)["Authorization"] }
        let(:id) { create(:user).id }

        run_test!
      end
    end
  end
end
