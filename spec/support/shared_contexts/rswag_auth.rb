# frozen_string_literal: true

RSpec.shared_context "rswag_admin" do
  let(:admin_user) { create(:user, :admin) }
  let(:Authorization) { auth_headers_for(admin_user)["Authorization"] }
end

RSpec.shared_context "rswag_instructor" do
  let(:instructor_user) { create(:user, :instructor) }
  let(:Authorization) { auth_headers_for(instructor_user)["Authorization"] }
end

RSpec.shared_context "rswag_student" do
  let(:student_user) { create(:user, :student) }
  let(:Authorization) { auth_headers_for(student_user)["Authorization"] }
end
