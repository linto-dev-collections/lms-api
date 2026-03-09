# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Api::V1::Reviews", type: :request do
  path "/api/v1/courses/{course_id}/reviews" do
    parameter name: :course_id, in: :path, type: :integer, required: true

    get "レビュー一覧（認証不要）" do
      tags "Reviews"
      produces "application/json"

      parameter name: :page, in: :query, type: :integer, required: false
      parameter name: :items, in: :query, type: :integer, required: false

      response "200", "レビュー一覧取得成功" do
        schema type: :object,
               properties: {
                 reviews: { type: :array, items: { "$ref" => "#/components/schemas/review" } },
                 meta: { "$ref" => "#/components/schemas/pagination_meta" }
               },
               required: %w[reviews meta]

        let(:course) { create(:course, :published) }
        let(:course_id) { course.id }

        before do
          create(:review, course: course)
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["reviews"]).not_to be_empty
        end
      end
    end

    post "レビュー投稿" do
      tags "Reviews"
      consumes "application/json"
      produces "application/json"
      security [ bearer_auth: [] ]

      parameter name: :params, in: :body, schema: {
        "$ref" => "#/components/schemas/review_params"
      }

      response "201", "レビュー投稿成功" do
        schema "$ref" => "#/components/schemas/review"

        let(:student) { create(:user, :student) }
        let(:course) { create(:course, :published) }
        let(:course_id) { course.id }
        let(:Authorization) { auth_headers_for(student)["Authorization"] }
        let(:params) { { review: { rating: 5, comment: "素晴らしい" } } }

        before do
          create(:enrollment, :completed, user: student, course: course)
        end

        run_test!
      end

      response "403", "未修了のコースにはレビュー不可" do
        schema "$ref" => "#/components/schemas/error_response"

        let(:student) { create(:user, :student) }
        let(:course) { create(:course, :published) }
        let(:course_id) { course.id }
        let(:Authorization) { auth_headers_for(student)["Authorization"] }
        let(:params) { { review: { rating: 4, comment: "テスト" } } }

        before do
          create(:enrollment, :active, user: student, course: course)
        end

        run_test!
      end

      response "201", "匿名レビュー投稿" do
        schema "$ref" => "#/components/schemas/review"

        let(:student) { create(:user, :student) }
        let(:course) { create(:course, :published) }
        let(:course_id) { course.id }
        let(:Authorization) { auth_headers_for(student)["Authorization"] }
        let(:params) { { review: { rating: 4, anonymous: true } } }

        before do
          create(:enrollment, :completed, user: student, course: course)
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["user"]["id"]).to be_nil
          expect(data["user"]["name"]).to eq("匿名")
        end
      end

      response "422", "重複レビュー" do
        schema "$ref" => "#/components/schemas/error_response"

        let(:student) { create(:user, :student) }
        let(:course) { create(:course, :published) }
        let(:course_id) { course.id }
        let(:Authorization) { auth_headers_for(student)["Authorization"] }
        let(:params) { { review: { rating: 3, comment: "2回目" } } }

        before do
          create(:enrollment, :completed, user: student, course: course)
          create(:review, user: student, course: course)
        end

        run_test!
      end

      response "422", "不正な評価値" do
        schema "$ref" => "#/components/schemas/error_response"

        let(:student) { create(:user, :student) }
        let(:course) { create(:course, :published) }
        let(:course_id) { course.id }
        let(:Authorization) { auth_headers_for(student)["Authorization"] }
        let(:params) { { review: { rating: 0, comment: "テスト" } } }

        before do
          create(:enrollment, :completed, user: student, course: course)
        end

        run_test!
      end
    end
  end

  path "/api/v1/reviews/{id}" do
    parameter name: :id, in: :path, type: :integer, required: true

    patch "レビュー更新" do
      tags "Reviews"
      consumes "application/json"
      produces "application/json"
      security [ bearer_auth: [] ]

      parameter name: :params, in: :body, schema: {
        "$ref" => "#/components/schemas/review_params"
      }

      response "200", "レビュー更新成功" do
        schema "$ref" => "#/components/schemas/review"

        let(:student) { create(:user, :student) }
        let(:course) { create(:course, :published) }
        let(:review) { create(:review, user: student, course: course) }
        let(:id) { review.id }
        let(:Authorization) { auth_headers_for(student)["Authorization"] }
        let(:params) { { review: { rating: 3, comment: "更新" } } }

        run_test! do
          expect(review.reload.rating).to eq(3)
        end
      end

      response "403", "他のユーザーのレビューは更新不可" do
        schema "$ref" => "#/components/schemas/error_response"

        let(:student) { create(:user, :student) }
        let(:other_student) { create(:user, :student) }
        let(:course) { create(:course, :published) }
        let(:review) { create(:review, user: other_student, course: course) }
        let(:id) { review.id }
        let(:Authorization) { auth_headers_for(student)["Authorization"] }
        let(:params) { { review: { rating: 1 } } }

        run_test!
      end
    end

    delete "レビュー削除" do
      tags "Reviews"
      security [ bearer_auth: [] ]

      response "204", "自分のレビュー削除成功" do
        let(:student) { create(:user, :student) }
        let(:course) { create(:course, :published) }
        let(:review) { create(:review, user: student, course: course) }
        let(:id) { review.id }
        let(:Authorization) { auth_headers_for(student)["Authorization"] }

        run_test!
      end

      response "204", "管理者は任意のレビューを削除可能" do
        let(:admin) { create(:user, :admin) }
        let(:student) { create(:user, :student) }
        let(:course) { create(:course, :published) }
        let(:review) { create(:review, user: student, course: course) }
        let(:id) { review.id }
        let(:Authorization) { auth_headers_for(admin)["Authorization"] }

        run_test!
      end
    end
  end
end
