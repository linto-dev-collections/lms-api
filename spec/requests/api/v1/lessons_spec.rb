# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Api::V1::Lessons", type: :request do
  path "/api/v1/lessons/{id}" do
    parameter name: :id, in: :path, type: :integer, required: true

    get "レッスン詳細" do
      tags "Lessons"
      produces "application/json"
      security [ bearer_auth: [] ]

      response "200", "講師によるレッスン取得" do
        schema "$ref" => "#/components/schemas/lesson"

        let(:instructor) { create(:user, :instructor) }
        let(:course) { create(:course, :published, instructor: instructor) }
        let(:section) { create(:section, course: course) }
        let(:lesson) { create(:lesson, section: section) }
        let(:id) { lesson.id }
        let(:Authorization) { auth_headers_for(instructor)["Authorization"] }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["title"]).to eq(lesson.title)
          expect(data["content_body"]).to be_present
        end
      end

      response "200", "受講済み受講者によるレッスン取得" do
        schema "$ref" => "#/components/schemas/lesson"

        let(:student) { create(:user, :student) }
        let(:course) { create(:course, :published) }
        let(:section) { create(:section, course: course) }
        let(:lesson) { create(:lesson, section: section) }
        let(:id) { lesson.id }
        let(:Authorization) { auth_headers_for(student)["Authorization"] }

        before do
          create(:enrollment, user: student, course: course, status: :active)
        end

        run_test!
      end

      response "403", "未受講の受講者はレッスン閲覧不可" do
        schema "$ref" => "#/components/schemas/error_response"

        let(:student) { create(:user, :student) }
        let(:course) { create(:course, :published) }
        let(:section) { create(:section, course: course) }
        let(:lesson) { create(:lesson, section: section) }
        let(:id) { lesson.id }
        let(:Authorization) { auth_headers_for(student)["Authorization"] }

        run_test!
      end
    end

    patch "レッスン更新" do
      tags "Lessons"
      consumes "application/json"
      produces "application/json"
      security [ bearer_auth: [] ]

      parameter name: :params, in: :body, schema: {
        "$ref" => "#/components/schemas/lesson_params"
      }

      response "200", "レッスン更新成功" do
        schema "$ref" => "#/components/schemas/lesson"

        let(:instructor) { create(:user, :instructor) }
        let(:course) { create(:course, :published, instructor: instructor) }
        let(:section) { create(:section, course: course) }
        let(:lesson) { create(:lesson, section: section) }
        let(:id) { lesson.id }
        let(:Authorization) { auth_headers_for(instructor)["Authorization"] }
        let(:params) { { lesson: { title: "更新レッスン" } } }

        run_test! do
          expect(lesson.reload.title).to eq("更新レッスン")
        end
      end
    end

    delete "レッスン削除" do
      tags "Lessons"
      security [ bearer_auth: [] ]

      response "204", "レッスン削除成功" do
        let(:instructor) { create(:user, :instructor) }
        let(:course) { create(:course, :published, instructor: instructor) }
        let(:section) { create(:section, course: course) }
        let(:lesson) { create(:lesson, section: section) }
        let(:id) { lesson.id }
        let(:Authorization) { auth_headers_for(instructor)["Authorization"] }

        run_test! do
          expect(Lesson.exists?(id)).to be false
        end
      end
    end
  end

  path "/api/v1/sections/{section_id}/lessons" do
    parameter name: :section_id, in: :path, type: :integer, required: true

    post "レッスン作成" do
      tags "Lessons"
      consumes "application/json"
      produces "application/json"
      security [ bearer_auth: [] ]

      parameter name: :params, in: :body, schema: {
        "$ref" => "#/components/schemas/lesson_params"
      }

      response "201", "レッスン作成成功" do
        schema "$ref" => "#/components/schemas/lesson"

        let(:instructor) { create(:user, :instructor) }
        let(:course) { create(:course, instructor: instructor) }
        let(:section) { create(:section, course: course) }
        let(:section_id) { section.id }
        let(:Authorization) { auth_headers_for(instructor)["Authorization"] }
        let(:params) do
          { lesson: { title: "新レッスン", content_type: "text", content_body: "内容", duration_minutes: 15, position: 1 } }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["title"]).to eq("新レッスン")
        end
      end

      response "403", "他の講師のセクションにはレッスン作成不可" do
        schema "$ref" => "#/components/schemas/error_response"

        let(:instructor) { create(:user, :instructor) }
        let(:other_instructor) { create(:user, :instructor) }
        let(:course) { create(:course, instructor: other_instructor) }
        let(:section) { create(:section, course: course) }
        let(:section_id) { section.id }
        let(:Authorization) { auth_headers_for(instructor)["Authorization"] }
        let(:params) do
          { lesson: { title: "Hacked", content_type: "text", content_body: "内容", duration_minutes: 15, position: 1 } }
        end

        run_test!
      end
    end
  end
end
