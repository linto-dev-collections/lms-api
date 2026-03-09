# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Api::V1::LessonProgresses", type: :request do
  path "/api/v1/lessons/{id}/progress" do
    parameter name: :id, in: :path, type: :integer, required: true

    post "レッスン進捗記録" do
      tags "LessonProgresses"
      consumes "application/json"
      produces "application/json"
      security [ bearer_auth: [] ]

      parameter name: :params, in: :body, schema: {
        "$ref" => "#/components/schemas/lesson_progress_params"
      }

      response "201", "レッスン進捗作成成功" do
        schema "$ref" => "#/components/schemas/lesson_progress"

        let(:student) { create(:user, :student) }
        let(:course) { create(:course, :published) }
        let(:section) { create(:section, course: course) }
        let(:lesson) { create(:lesson, section: section) }
        let(:enrollment) { create(:enrollment, :active, user: student, course: course) }
        let(:id) { lesson.id }
        let(:Authorization) { auth_headers_for(student)["Authorization"] }
        let(:params) { { progress: { status: "completed" } } }

        before { enrollment }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["status"]).to eq("completed")

          # 修了トリガーテスト: 全レッスン完了で enrollment が completed になる
          expect(enrollment.reload.status).to eq("completed")
          expect(enrollment.certificate).to be_present
          expect(enrollment.certificate.status).to eq("issued")
        end
      end

      response "200", "レッスン進捗更新成功" do
        schema "$ref" => "#/components/schemas/lesson_progress"

        let(:student) { create(:user, :student) }
        let(:course) { create(:course, :published) }
        let(:section) { create(:section, course: course) }
        let(:lesson) { create(:lesson, section: section) }
        let(:enrollment) { create(:enrollment, :active, user: student, course: course) }
        let(:id) { lesson.id }
        let(:Authorization) { auth_headers_for(student)["Authorization"] }
        let(:params) { { progress: { status: "completed" } } }

        before do
          enrollment
          create(:lesson_progress, :in_progress, enrollment: enrollment, lesson: lesson)
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["status"]).to eq("completed")
        end
      end

      response "404", "未受講のレッスンへの進捗記録は不可" do
        schema "$ref" => "#/components/schemas/error_response"

        let(:student) { create(:user, :student) }
        let(:course) { create(:course, :published) }
        let(:section) { create(:section, course: course) }
        let(:lesson) { create(:lesson, section: section) }
        let(:id) { lesson.id }
        let(:Authorization) { auth_headers_for(student)["Authorization"] }
        let(:params) { { progress: { status: "in_progress" } } }

        run_test!
      end
    end
  end
end
