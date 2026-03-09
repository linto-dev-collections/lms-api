# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Api::V1::Enrollments", type: :request do
  path "/api/v1/courses/{course_id}/enrollments" do
    parameter name: :course_id, in: :path, type: :integer, required: true

    post "受講登録" do
      tags "Enrollments"
      produces "application/json"
      security [ bearer_auth: [] ]

      response "201", "受講登録成功" do
        schema "$ref" => "#/components/schemas/enrollment"

        let(:student) { create(:user, :student) }
        let(:course) { create(:course, :published) }
        let(:course_id) { course.id }
        let(:Authorization) { auth_headers_for(student)["Authorization"] }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["status"]).to eq("pending")
        end
      end

      response "409", "重複登録" do
        schema "$ref" => "#/components/schemas/error_response"

        let(:student) { create(:user, :student) }
        let(:course) { create(:course, :published) }
        let(:course_id) { course.id }
        let(:Authorization) { auth_headers_for(student)["Authorization"] }

        before { create(:enrollment, user: student, course: course) }

        run_test!
      end

      response "403", "受講者ロール以外は登録不可" do
        schema "$ref" => "#/components/schemas/error_response"

        let(:instructor) { create(:user, :instructor) }
        let(:course) { create(:course, :published) }
        let(:course_id) { course.id }
        let(:Authorization) { auth_headers_for(instructor)["Authorization"] }

        run_test!
      end

      response "422", "未公開コースへの登録不可" do
        schema "$ref" => "#/components/schemas/error_response"

        let(:student) { create(:user, :student) }
        let(:course) { create(:course) }
        let(:course_id) { course.id }
        let(:Authorization) { auth_headers_for(student)["Authorization"] }

        run_test!
      end

      response "422", "定員超過" do
        schema "$ref" => "#/components/schemas/error_response"

        let(:student) { create(:user, :student) }
        let(:course) { create(:course, :published, max_enrollment: 1) }
        let(:course_id) { course.id }
        let(:Authorization) { auth_headers_for(student)["Authorization"] }

        before { create(:enrollment, course: course) }

        run_test!
      end
    end
  end

  path "/api/v1/enrollments" do
    get "受講一覧" do
      tags "Enrollments"
      produces "application/json"
      security [ bearer_auth: [] ]

      parameter name: :page, in: :query, type: :integer, required: false
      parameter name: :items, in: :query, type: :integer, required: false

      response "200", "受講一覧取得成功" do
        schema type: :object,
               properties: {
                 enrollments: { type: :array, items: { "$ref" => "#/components/schemas/enrollment" } },
                 meta: { "$ref" => "#/components/schemas/pagination_meta" }
               },
               required: %w[enrollments meta]

        let(:student) { create(:user, :student) }
        let(:Authorization) { auth_headers_for(student)["Authorization"] }

        before do
          create(:enrollment, user: student, course: create(:course, :published))
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["enrollments"].size).to eq(1)
          expect(data).to have_key("meta")
        end
      end
    end
  end

  path "/api/v1/enrollments/{id}" do
    parameter name: :id, in: :path, type: :integer, required: true

    get "受講詳細" do
      tags "Enrollments"
      produces "application/json"
      security [ bearer_auth: [] ]

      response "200", "受講詳細取得成功" do
        schema "$ref" => "#/components/schemas/enrollment"

        let(:student) { create(:user, :student) }
        let(:course) { create(:course, :published) }
        let(:enrollment) { create(:enrollment, user: student, course: course) }
        let(:id) { enrollment.id }
        let(:Authorization) { auth_headers_for(student)["Authorization"] }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["status"]).to eq("pending")
          expect(data).to have_key("progress")
        end
      end
    end
  end

  path "/api/v1/enrollments/{id}/activate" do
    parameter name: :id, in: :path, type: :integer, required: true

    post "受講開始" do
      tags "Enrollments"
      produces "application/json"
      security [ bearer_auth: [] ]

      response "200", "受講開始成功" do
        schema "$ref" => "#/components/schemas/enrollment"

        let(:student) { create(:user, :student) }
        let(:course) { create(:course, :published) }
        let(:enrollment) { create(:enrollment, user: student, course: course, status: :pending) }
        let(:id) { enrollment.id }
        let(:Authorization) { auth_headers_for(student)["Authorization"] }

        run_test! do
          expect(enrollment.reload.status).to eq("active")
        end
      end
    end
  end

  path "/api/v1/enrollments/{id}/suspend" do
    parameter name: :id, in: :path, type: :integer, required: true

    post "受講停止" do
      tags "Enrollments"
      produces "application/json"
      security [ bearer_auth: [] ]

      response "200", "受講停止成功" do
        schema "$ref" => "#/components/schemas/enrollment"

        let(:student) { create(:user, :student) }
        let(:course) { create(:course, :published) }
        let(:enrollment) { create(:enrollment, :active, user: student, course: course) }
        let(:id) { enrollment.id }
        let(:Authorization) { auth_headers_for(student)["Authorization"] }

        run_test! do
          expect(enrollment.reload.status).to eq("suspended")
        end
      end
    end
  end

  path "/api/v1/enrollments/{id}/resume" do
    parameter name: :id, in: :path, type: :integer, required: true

    post "受講再開" do
      tags "Enrollments"
      produces "application/json"
      security [ bearer_auth: [] ]

      response "200", "受講再開成功" do
        schema "$ref" => "#/components/schemas/enrollment"

        let(:student) { create(:user, :student) }
        let(:course) { create(:course, :published) }
        let(:enrollment) { create(:enrollment, :suspended, user: student, course: course) }
        let(:id) { enrollment.id }
        let(:Authorization) { auth_headers_for(student)["Authorization"] }

        run_test! do
          expect(enrollment.reload.status).to eq("active")
        end
      end
    end
  end

  path "/api/v1/enrollments/{id}/progress" do
    parameter name: :id, in: :path, type: :integer, required: true

    get "進捗確認" do
      tags "Enrollments"
      produces "application/json"
      security [ bearer_auth: [] ]

      response "200", "進捗取得成功" do
        schema type: :object,
               properties: {
                 summary: {
                   type: :object,
                   properties: {
                     total_lessons: { type: :integer },
                     completed_lessons: { type: :integer },
                     in_progress_lessons: { type: :integer },
                     not_started_lessons: { type: :integer },
                     completion_percentage: { type: :number }
                   }
                 },
                 lesson_progresses: {
                   type: :array,
                   items: { "$ref" => "#/components/schemas/lesson_progress" }
                 }
               },
               required: %w[summary lesson_progresses]

        let(:student) { create(:user, :student) }
        let(:course) { create(:course, :published) }
        let(:enrollment) { create(:enrollment, :active, user: student, course: course) }
        let(:id) { enrollment.id }
        let(:Authorization) { auth_headers_for(student)["Authorization"] }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key("summary")
          expect(data).to have_key("lesson_progresses")
        end
      end
    end
  end
end
