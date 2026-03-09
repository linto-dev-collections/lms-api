require "rails_helper"

RSpec.describe LessonProgress, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:enrollment) }
    it { is_expected.to belong_to(:lesson) }
  end

  describe "validations" do
    subject { build(:lesson_progress) }

    it { is_expected.to validate_uniqueness_of(:enrollment_id).scoped_to(:lesson_id) }
    it { is_expected.to validate_presence_of(:status) }
  end

  describe "enums" do
    it { is_expected.to define_enum_for(:status).backed_by_column_of_type(:string).with_values(not_started: "not_started", in_progress: "in_progress", completed: "completed") }
  end

  describe "scopes" do
    it ".completed returns only completed progresses" do
      completed = create(:lesson_progress, :completed)
      create(:lesson_progress, :in_progress)

      expect(described_class.completed).to eq([ completed ])
    end
  end
end
