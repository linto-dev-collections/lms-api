require "rails_helper"

RSpec.describe "Full Enrollment Flow", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:instructor) { create(:user, :instructor) }
  let(:student) { create(:user, :student) }

  it "completes the full flow: create course → enroll → complete → certificate" do
    # 1. 講師がコースを作成
    post "/api/v1/courses",
         params: { course: { title: "Ruby入門", description: "基礎講座", category: "programming", difficulty: "beginner" } },
         headers: auth_headers_for(instructor)
    expect(response).to have_http_status(:created)
    course_id = response.parsed_body["id"]

    # 2. セクションを作成
    post "/api/v1/courses/#{course_id}/sections",
         params: { section: { title: "第1章", position: 0 } },
         headers: auth_headers_for(instructor)
    expect(response).to have_http_status(:created)
    section_id = response.parsed_body["id"]

    # 3. レッスンを作成
    post "/api/v1/sections/#{section_id}/lessons",
         params: { lesson: { title: "レッスン1", content_type: "text", content_body: "内容", duration_minutes: 30, position: 0 } },
         headers: auth_headers_for(instructor)
    expect(response).to have_http_status(:created)
    lesson_id = response.parsed_body["id"]

    # 4. レビュー提出
    post "/api/v1/courses/#{course_id}/submit_for_review",
         headers: auth_headers_for(instructor)
    expect(response).to have_http_status(:ok)

    # 5. 管理者が承認
    post "/api/v1/courses/#{course_id}/approve",
         headers: auth_headers_for(admin)
    expect(response).to have_http_status(:ok)

    # 6. 受講者が受講登録
    post "/api/v1/courses/#{course_id}/enrollments",
         headers: auth_headers_for(student)
    expect(response).to have_http_status(:created)
    enrollment_id = response.parsed_body["id"]

    # 7. 受講開始
    post "/api/v1/enrollments/#{enrollment_id}/activate",
         headers: auth_headers_for(student)
    expect(response).to have_http_status(:ok)

    # 8. レッスン完了
    post "/api/v1/lessons/#{lesson_id}/progress",
         params: { progress: { status: "completed" } },
         headers: auth_headers_for(student)
    expect(response).to have_http_status(:created)

    # 9. 修了確認
    enrollment = Enrollment.find(enrollment_id)
    expect(enrollment.reload.status).to eq("completed")

    # 10. 修了証確認
    get "/api/v1/certificates",
        headers: auth_headers_for(student)
    expect(response).to have_http_status(:ok)
    expect(response.parsed_body["certificates"]).not_to be_empty

    # 11. 通知確認（テスト環境では abstract_notifier がインターセプトするため enqueued_deliveries で確認）
    enqueued = AbstractNotifier::Testing::Driver.enqueued_deliveries
    notification_types = enqueued.map { |d| d[:notification_type] }
    expect(notification_types).to include("new_enrollment")
    expect(notification_types).to include("certificate_issued")
  end
end
