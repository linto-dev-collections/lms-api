require "rails_helper"

RSpec.describe EnrollmentMailer, type: :mailer do
  let(:instructor) { create(:user, :instructor) }
  let(:student) { create(:user, :student) }
  let(:course) { create(:course, :published, instructor: instructor) }
  let(:enrollment) { create(:enrollment, :active, user: student, course: course) }

  describe "#new_enrollment" do
    subject(:mail) do
      described_class.with(enrollment: enrollment).new_enrollment
    end

    it "sends to the instructor" do
      expect(mail.to).to eq([ instructor.email ])
    end

    it "includes the course title in subject" do
      expect(mail.subject).to include(course.title)
    end

    it "includes the student name in body" do
      expect(mail.body.encoded).to include(student.name)
    end
  end

  describe "#enrollment_created" do
    subject(:mail) do
      described_class.with(enrollment: enrollment).enrollment_created
    end

    it "sends to the student" do
      expect(mail.to).to eq([ student.email ])
    end

    it "includes the course title in subject" do
      expect(mail.subject).to include(course.title)
    end
  end

  describe "#new_review" do
    let(:review) { create(:review, course: course, user: student) }

    subject(:mail) do
      described_class.with(review: review).new_review
    end

    it "sends to the instructor" do
      expect(mail.to).to eq([ instructor.email ])
    end

    it "includes the rating in subject" do
      expect(mail.subject).to include(review.rating.to_s)
    end
  end
end
