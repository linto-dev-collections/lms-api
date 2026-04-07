require "rails_helper"

RSpec.describe CourseMailer, type: :mailer do
  let(:instructor) { create(:user, :instructor) }
  let(:course) { create(:course, :published, instructor: instructor) }

  describe "#course_approved" do
    subject(:mail) do
      described_class.with(course: course).course_approved
    end

    it "sends to the instructor" do
      expect(mail.to).to eq([ instructor.email ])
    end

    it "includes the course title in subject" do
      expect(mail.subject).to include(course.title)
    end
  end

  describe "#course_rejected" do
    subject(:mail) do
      described_class.with(course: course, reason: "内容が不十分です").course_rejected
    end

    it "sends to the instructor" do
      expect(mail.to).to eq([ instructor.email ])
    end

    it "includes the reason in body" do
      expect(mail.body.encoded).to include("内容が不十分です")
    end
  end
end
