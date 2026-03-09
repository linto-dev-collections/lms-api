# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Api::V1::Admin::Dashboard", type: :request do
  path "/api/v1/admin/dashboard" do
    get "ダッシュボード統計" do
      tags "Admin"
      produces "application/json"
      security [ bearer_auth: [] ]

      response "200", "統計取得成功" do
        schema "$ref" => "#/components/schemas/dashboard"

        let(:admin) { create(:user, :admin) }
        let(:Authorization) { auth_headers_for(admin)["Authorization"] }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["dashboard"]).to have_key("users")
          expect(data["dashboard"]).to have_key("courses")
          expect(data["dashboard"]).to have_key("enrollments")
          expect(data["dashboard"]).to have_key("certificates")
          expect(data["dashboard"]).to have_key("reviews")
        end
      end

      response "403", "非管理者はアクセス不可" do
        schema "$ref" => "#/components/schemas/error_response"

        let(:student) { create(:user, :student) }
        let(:Authorization) { auth_headers_for(student)["Authorization"] }

        run_test!
      end
    end
  end

  path "/api/v1/admin/courses" do
    get "管理者向けコース一覧" do
      tags "Admin"
      produces "application/json"
      security [ bearer_auth: [] ]

      parameter name: :page, in: :query, type: :integer, required: false
      parameter name: :items, in: :query, type: :integer, required: false

      response "200", "コース一覧取得成功" do
        schema type: :object,
               properties: {
                 courses: { type: :array, items: { "$ref" => "#/components/schemas/course_instructor" } },
                 meta: { "$ref" => "#/components/schemas/pagination_meta" }
               },
               required: %w[courses meta]

        let(:admin) { create(:user, :admin) }
        let(:Authorization) { auth_headers_for(admin)["Authorization"] }

        before do
          create_list(:course, 3)
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["courses"].size).to eq(3)
        end
      end
    end
  end

  path "/api/v1/admin/courses/pending_review" do
    get "レビュー待ちコース一覧" do
      tags "Admin"
      produces "application/json"
      security [ bearer_auth: [] ]

      response "200", "レビュー待ちコース取得成功" do
        schema type: :object,
               properties: {
                 courses: { type: :array, items: { "$ref" => "#/components/schemas/course_instructor" } },
                 meta: { "$ref" => "#/components/schemas/pagination_meta" }
               },
               required: %w[courses meta]

        let(:admin) { create(:user, :admin) }
        let(:Authorization) { auth_headers_for(admin)["Authorization"] }

        before do
          create(:course, :under_review)
          create(:course, :published)
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["courses"].size).to eq(1)
        end
      end
    end
  end
end
