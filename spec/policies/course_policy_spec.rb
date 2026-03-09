require "rails_helper"

RSpec.describe CoursePolicy do
  let(:admin) { build(:user, :admin) }
  let(:instructor) { create(:user, :instructor) }
  let(:other_instructor) { create(:user, :instructor) }
  let(:student) { build(:user, :student) }
  let(:course) { create(:course, instructor: instructor) }

  describe "#show?" do
    it "allows admin" do
      expect(described_class.new(course, user: admin)).to be_allowed_to(:show?)
    end

    it "allows course owner" do
      expect(described_class.new(course, user: instructor)).to be_allowed_to(:show?)
    end

    it "denies student for draft course" do
      expect(described_class.new(course, user: student)).not_to be_allowed_to(:show?)
    end

    it "allows student for published course" do
      published = create(:course, :published)
      expect(described_class.new(published, user: student)).to be_allowed_to(:show?)
    end
  end

  describe "#create?" do
    it "allows instructor" do
      expect(described_class.new(course, user: instructor)).to be_allowed_to(:create?)
    end

    it "denies student" do
      expect(described_class.new(course, user: student)).not_to be_allowed_to(:create?)
    end
  end

  describe "#update?" do
    it "allows admin" do
      expect(described_class.new(course, user: admin)).to be_allowed_to(:update?)
    end

    it "allows course owner" do
      expect(described_class.new(course, user: instructor)).to be_allowed_to(:update?)
    end

    it "denies other instructor" do
      expect(described_class.new(course, user: other_instructor)).not_to be_allowed_to(:update?)
    end

    it "denies student" do
      expect(described_class.new(course, user: student)).not_to be_allowed_to(:update?)
    end
  end

  describe "#destroy?" do
    it "allows admin" do
      expect(described_class.new(course, user: admin)).to be_allowed_to(:destroy?)
    end

    it "allows owner for draft course" do
      expect(described_class.new(course, user: instructor)).to be_allowed_to(:destroy?)
    end

    it "denies owner for non-draft course" do
      published = create(:course, :published, instructor: instructor)
      expect(described_class.new(published, user: instructor)).not_to be_allowed_to(:destroy?)
    end
  end

  describe "#approve?" do
    it "allows admin" do
      expect(described_class.new(course, user: admin)).to be_allowed_to(:approve?)
    end

    it "denies instructor" do
      expect(described_class.new(course, user: instructor)).not_to be_allowed_to(:approve?)
    end
  end

  describe "relation_scope" do
    let!(:published_course) { create(:course, :published) }
    let!(:draft_course) { create(:course, instructor: instructor) }

    it "returns all courses for admin" do
      scope = described_class.new(Course, user: admin).apply_scope(Course.all, type: :active_record_relation)
      expect(scope).to include(published_course, draft_course)
    end

    it "returns only instructor's courses for instructor" do
      scope = described_class.new(Course, user: instructor).apply_scope(Course.all, type: :active_record_relation)
      expect(scope).to include(draft_course)
      expect(scope).not_to include(published_course) unless published_course.instructor_id == instructor.id
    end

    it "returns only published courses for student" do
      scope = described_class.new(Course, user: student).apply_scope(Course.all, type: :active_record_relation)
      expect(scope).to include(published_course)
      expect(scope).not_to include(draft_course)
    end
  end
end
