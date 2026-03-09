# frozen_string_literal: true

require "swagger_helper"

RSpec.describe "Api::V1::Courses", type: :request do
  path "/api/v1/courses" do
    get "コース一覧" do
      tags "Courses"
      produces "application/json"
      security [ bearer_auth: [] ]

      parameter name: :q, in: :query, type: :string, required: false, description: "キーワード検索"
      parameter name: :category, in: :query, type: :string, required: false
      parameter name: :difficulty, in: :query, type: :string, required: false
      parameter name: :page, in: :query, type: :integer, required: false
      parameter name: :items, in: :query, type: :integer, required: false

      response "200", "コース一覧取得成功" do
        schema type: :object,
               properties: {
                 courses: { type: :array, items: { "$ref" => "#/components/schemas/course" } },
                 meta: { "$ref" => "#/components/schemas/pagination_meta" }
               },
               required: %w[courses meta]

        let(:instructor) { create(:user, :instructor) }
        let(:admin) { create(:user, :admin) }
        let(:student) { create(:user, :student) }
        let!(:published_course) { create(:course, :published) }
        let!(:draft_course) { create(:course, instructor: instructor) }
        let(:Authorization) { auth_headers_for(student)["Authorization"] }

        run_test! do |response|
          data = JSON.parse(response.body)
          # student は published のみ
          titles = data["courses"].map { |c| c["title"] }
          expect(titles).to include(published_course.title)
          expect(titles).not_to include(draft_course.title)

          # ページネーション meta
          expect(data["meta"]).to include("current_page", "total_pages", "total_count", "per_page")

          # unauthenticated は published のみ
          get "/api/v1/courses"
          unauthenticated_data = JSON.parse(self.response.body)
          unauthenticated_titles = unauthenticated_data["courses"].map { |c| c["title"] }
          expect(unauthenticated_titles).to include(published_course.title)
          expect(unauthenticated_titles).not_to include(draft_course.title)

          # instructor は自分のコースを含む
          get "/api/v1/courses", headers: auth_headers_for(instructor)
          instructor_data = JSON.parse(self.response.body)
          instructor_titles = instructor_data["courses"].map { |c| c["title"] }
          expect(instructor_titles).to include(draft_course.title)

          # admin は全コース
          get "/api/v1/courses", headers: auth_headers_for(admin)
          admin_data = JSON.parse(self.response.body)
          admin_titles = admin_data["courses"].map { |c| c["title"] }
          expect(admin_titles).to include(published_course.title, draft_course.title)

          # keyword フィルタ
          get "/api/v1/courses", params: { q: published_course.title }
          filter_data = JSON.parse(self.response.body)
          expect(filter_data["courses"].size).to eq(1)
        end
      end
    end

    post "コース作成" do
      tags "Courses"
      consumes "application/json"
      produces "application/json"
      security [ bearer_auth: [] ]

      parameter name: :params, in: :body, schema: {
        "$ref" => "#/components/schemas/course_create_params"
      }

      response "201", "コース作成成功" do
        schema "$ref" => "#/components/schemas/course_instructor"

        let(:instructor) { create(:user, :instructor) }
        let(:Authorization) { auth_headers_for(instructor)["Authorization"] }
        let(:params) do
          { course: { title: "Ruby入門", description: "基礎講座", category: "programming", difficulty: "beginner" } }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["title"]).to eq("Ruby入門")
          expect(data["status"]).to eq("draft")
        end
      end

      response "403", "受講者はコース作成不可" do
        schema "$ref" => "#/components/schemas/error_response"

        let(:student) { create(:user, :student) }
        let(:Authorization) { auth_headers_for(student)["Authorization"] }
        let(:params) { { course: { title: "Test" } } }

        run_test!
      end

      response "422", "バリデーションエラー" do
        schema "$ref" => "#/components/schemas/error_response"

        let(:instructor) { create(:user, :instructor) }
        let(:Authorization) { auth_headers_for(instructor)["Authorization"] }
        let(:params) { { course: { title: "", description: "", category: "", difficulty: "expert" } } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["error"]["code"]).to eq("validation_failed")
        end
      end
    end
  end

  path "/api/v1/courses/{id}" do
    parameter name: :id, in: :path, type: :integer, required: true

    get "コース詳細" do
      tags "Courses"
      produces "application/json"
      security [ bearer_auth: [] ]

      response "200", "コース詳細取得成功" do
        schema "$ref" => "#/components/schemas/course_detail"

        let(:course) { create(:course, :published, :with_content) }
        let(:id) { course.id }
        let(:student) { create(:user, :student) }
        let(:Authorization) { auth_headers_for(student)["Authorization"] }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["title"]).to eq(course.title)
          expect(data).to have_key("sections")
          expect(data).to have_key("total_duration_minutes")
          expect(data).to have_key("total_lessons")
        end
      end

      response "200", "講師向けコース詳細" do
        schema "$ref" => "#/components/schemas/course_instructor"

        let(:instructor) { create(:user, :instructor) }
        let(:course) { create(:course, :with_content, instructor: instructor) }
        let(:id) { course.id }
        let(:Authorization) { auth_headers_for(instructor)["Authorization"] }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key("active_enrollment_count")
          expect(data).to have_key("review_count")
        end
      end

      response "404", "コースが見つからない" do
        schema "$ref" => "#/components/schemas/error_response"

        let(:id) { 0 }
        let(:Authorization) { auth_headers_for(create(:user, :student))["Authorization"] }

        run_test!
      end

      response "403", "他の講師のドラフトコースへのアクセス拒否" do
        schema "$ref" => "#/components/schemas/error_response"

        let(:instructor) { create(:user, :instructor) }
        let(:other_instructor) { create(:user, :instructor) }
        let(:course) { create(:course, instructor: other_instructor) }
        let(:id) { course.id }
        let(:Authorization) { auth_headers_for(instructor)["Authorization"] }

        run_test!
      end
    end

    patch "コース更新" do
      tags "Courses"
      consumes "application/json"
      produces "application/json"
      security [ bearer_auth: [] ]

      parameter name: :params, in: :body, schema: {
        "$ref" => "#/components/schemas/course_create_params"
      }

      response "200", "更新成功" do
        schema "$ref" => "#/components/schemas/course_instructor"

        let(:instructor) { create(:user, :instructor) }
        let(:course) { create(:course, instructor: instructor) }
        let(:id) { course.id }
        let(:Authorization) { auth_headers_for(instructor)["Authorization"] }
        let(:params) { { course: { title: "更新タイトル" } } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["title"]).to eq("更新タイトル")

          # admin も更新可能
          admin = create(:user, :admin)
          patch "/api/v1/courses/#{id}", params: { course: { title: "管理者更新" } },
                                         headers: auth_headers_for(admin)
          expect(self.response).to have_http_status(:ok)
        end
      end

      response "403", "他の講師のコースは更新不可" do
        schema "$ref" => "#/components/schemas/error_response"

        let(:instructor) { create(:user, :instructor) }
        let(:other_instructor) { create(:user, :instructor) }
        let(:course) { create(:course, instructor: other_instructor) }
        let(:id) { course.id }
        let(:Authorization) { auth_headers_for(instructor)["Authorization"] }
        let(:params) { { course: { title: "Hacked" } } }

        run_test!
      end
    end

    delete "コース削除" do
      tags "Courses"
      security [ bearer_auth: [] ]

      response "204", "削除成功" do
        let(:instructor) { create(:user, :instructor) }
        let(:course) { create(:course, instructor: instructor) }
        let(:id) { course.id }
        let(:Authorization) { auth_headers_for(instructor)["Authorization"] }

        run_test! do
          expect(Course.exists?(id)).to be false

          # admin は任意のコースを削除可能
          admin = create(:user, :admin)
          published_course = create(:course, :published)
          delete "/api/v1/courses/#{published_course.id}", headers: auth_headers_for(admin)
          expect(self.response).to have_http_status(:no_content)
        end
      end

      response "403", "公開済みコースの削除拒否（講師）" do
        schema "$ref" => "#/components/schemas/error_response"

        let(:instructor) { create(:user, :instructor) }
        let(:course) { create(:course, :published, instructor: instructor) }
        let(:id) { course.id }
        let(:Authorization) { auth_headers_for(instructor)["Authorization"] }

        run_test!
      end
    end
  end

  path "/api/v1/courses/{id}/submit_for_review" do
    parameter name: :id, in: :path, type: :integer, required: true

    post "レビュー提出" do
      tags "Courses"
      produces "application/json"
      security [ bearer_auth: [] ]

      response "200", "レビュー提出成功" do
        schema "$ref" => "#/components/schemas/course_instructor"

        let(:instructor) { create(:user, :instructor) }
        let(:course) { create(:course, :with_content, instructor: instructor) }
        let(:id) { course.id }
        let(:Authorization) { auth_headers_for(instructor)["Authorization"] }

        run_test! do
          expect(course.reload.status).to eq("under_review")
        end
      end

      response "409", "コンテンツなしでレビュー提出失敗" do
        schema "$ref" => "#/components/schemas/error_response"

        let(:instructor) { create(:user, :instructor) }
        let(:course) { create(:course, instructor: instructor) }
        let(:id) { course.id }
        let(:Authorization) { auth_headers_for(instructor)["Authorization"] }

        run_test!
      end
    end
  end

  path "/api/v1/courses/{id}/approve" do
    parameter name: :id, in: :path, type: :integer, required: true

    post "コース承認（管理者のみ）" do
      tags "Courses"
      produces "application/json"
      security [ bearer_auth: [] ]

      response "200", "承認成功" do
        schema "$ref" => "#/components/schemas/course"

        let(:admin) { create(:user, :admin) }
        let(:course) { create(:course, :under_review) }
        let(:id) { course.id }
        let(:Authorization) { auth_headers_for(admin)["Authorization"] }

        run_test! do
          expect(course.reload.status).to eq("published")
        end
      end

      response "403", "講師は承認不可" do
        schema "$ref" => "#/components/schemas/error_response"

        let(:instructor) { create(:user, :instructor) }
        let(:course) { create(:course, :under_review) }
        let(:id) { course.id }
        let(:Authorization) { auth_headers_for(instructor)["Authorization"] }

        run_test!
      end
    end
  end

  path "/api/v1/courses/{id}/reject" do
    parameter name: :id, in: :path, type: :integer, required: true

    post "コース却下（管理者のみ）" do
      tags "Courses"
      produces "application/json"
      security [ bearer_auth: [] ]

      parameter name: :params, in: :body, schema: {
        type: :object,
        properties: {
          reason: { type: :string, description: "却下理由" }
        }
      }, required: false

      response "200", "却下成功" do
        schema "$ref" => "#/components/schemas/course"

        let(:admin) { create(:user, :admin) }
        let(:course) { create(:course, :under_review) }
        let(:id) { course.id }
        let(:Authorization) { auth_headers_for(admin)["Authorization"] }
        let(:params) { { reason: "内容不十分" } }

        run_test! do
          expect(course.reload.status).to eq("rejected")
        end
      end
    end
  end

  path "/api/v1/courses/{id}/unpublish" do
    parameter name: :id, in: :path, type: :integer, required: true

    post "コース非公開化" do
      tags "Courses"
      produces "application/json"
      security [ bearer_auth: [] ]

      response "200", "非公開化成功" do
        schema "$ref" => "#/components/schemas/course"

        let(:instructor) { create(:user, :instructor) }
        let(:course) { create(:course, :published, instructor: instructor) }
        let(:id) { course.id }
        let(:Authorization) { auth_headers_for(instructor)["Authorization"] }

        run_test! do
          expect(course.reload.status).to eq("draft")
        end
      end
    end
  end

  path "/api/v1/courses/{id}/archive" do
    parameter name: :id, in: :path, type: :integer, required: true

    post "コースアーカイブ" do
      tags "Courses"
      produces "application/json"
      security [ bearer_auth: [] ]

      response "200", "アーカイブ成功" do
        schema "$ref" => "#/components/schemas/course"

        let(:instructor) { create(:user, :instructor) }
        let(:course) { create(:course, :published, instructor: instructor) }
        let(:id) { course.id }
        let(:Authorization) { auth_headers_for(instructor)["Authorization"] }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["archived"]).to be true
          expect(data["status"]).to eq("published")
        end
      end
    end
  end

  path "/api/v1/courses/{id}/unarchive" do
    parameter name: :id, in: :path, type: :integer, required: true

    post "コースアーカイブ解除" do
      tags "Courses"
      produces "application/json"
      security [ bearer_auth: [] ]

      response "200", "アーカイブ解除成功" do
        schema "$ref" => "#/components/schemas/course"

        let(:instructor) { create(:user, :instructor) }
        let(:course) { create(:course, :published, :archived, instructor: instructor) }
        let(:id) { course.id }
        let(:Authorization) { auth_headers_for(instructor)["Authorization"] }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["archived"]).to be false
        end
      end
    end
  end
end
