# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Api::V1::Sections", type: :request do
  path "/api/v1/courses/{course_id}/sections" do
    parameter name: :course_id, in: :path, type: :integer, required: true

    get "セクション一覧" do
      tags "Sections"
      produces "application/json"
      security [ bearer_auth: [] ]

      response "200", "セクション一覧取得成功" do
        schema type: :object,
               properties: {
                 sections: { type: :array, items: { "$ref" => "#/components/schemas/section" } }
               },
               required: %w[sections]

        let(:instructor) { create(:user, :instructor) }
        let(:course) { create(:course, instructor: instructor) }
        let(:course_id) { course.id }
        let(:Authorization) { auth_headers_for(instructor)["Authorization"] }

        before do
          section = create(:section, course: course)
          create(:lesson, section: section)
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["sections"].size).to eq(1)
          expect(data["sections"].first["lessons"]).to be_present
        end
      end
    end

    post "セクション作成" do
      tags "Sections"
      consumes "application/json"
      produces "application/json"
      security [ bearer_auth: [] ]

      parameter name: :params, in: :body, schema: {
        "$ref" => "#/components/schemas/section_params"
      }

      response "201", "セクション作成成功" do
        schema "$ref" => "#/components/schemas/section"

        let(:instructor) { create(:user, :instructor) }
        let(:course) { create(:course, instructor: instructor) }
        let(:course_id) { course.id }
        let(:Authorization) { auth_headers_for(instructor)["Authorization"] }
        let(:params) { { section: { title: "新セクション", position: 1 } } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["title"]).to eq("新セクション")
        end
      end

      response "403", "他の講師のコースにはセクション作成不可" do
        schema "$ref" => "#/components/schemas/error_response"

        let(:instructor) { create(:user, :instructor) }
        let(:other_instructor) { create(:user, :instructor) }
        let(:course) { create(:course, instructor: other_instructor) }
        let(:course_id) { course.id }
        let(:Authorization) { auth_headers_for(instructor)["Authorization"] }
        let(:params) { { section: { title: "Hacked", position: 0 } } }

        run_test!
      end
    end
  end

  path "/api/v1/sections/{id}" do
    parameter name: :id, in: :path, type: :integer, required: true

    patch "セクション更新" do
      tags "Sections"
      consumes "application/json"
      produces "application/json"
      security [ bearer_auth: [] ]

      parameter name: :params, in: :body, schema: {
        "$ref" => "#/components/schemas/section_params"
      }

      response "200", "セクション更新成功" do
        schema "$ref" => "#/components/schemas/section"

        let(:instructor) { create(:user, :instructor) }
        let(:course) { create(:course, instructor: instructor) }
        let(:section) { create(:section, course: course) }
        let(:id) { section.id }
        let(:Authorization) { auth_headers_for(instructor)["Authorization"] }
        let(:params) { { section: { title: "更新タイトル" } } }

        run_test! do
          expect(section.reload.title).to eq("更新タイトル")
        end
      end

      response "403", "他の講師のセクションは更新不可" do
        schema "$ref" => "#/components/schemas/error_response"

        let(:instructor) { create(:user, :instructor) }
        let(:other_instructor) { create(:user, :instructor) }
        let(:course) { create(:course, instructor: other_instructor) }
        let(:section) { create(:section, course: course) }
        let(:id) { section.id }
        let(:Authorization) { auth_headers_for(instructor)["Authorization"] }
        let(:params) { { section: { title: "Hacked" } } }

        run_test!
      end
    end

    delete "セクション削除" do
      tags "Sections"
      security [ bearer_auth: [] ]

      response "204", "セクション削除成功" do
        let(:instructor) { create(:user, :instructor) }
        let(:course) { create(:course, instructor: instructor) }
        let(:section) { create(:section, course: course) }
        let(:id) { section.id }
        let(:Authorization) { auth_headers_for(instructor)["Authorization"] }

        run_test! do
          expect(Section.exists?(id)).to be false
        end
      end
    end
  end
end
