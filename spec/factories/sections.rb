FactoryBot.define do
  factory :section do
    course
    sequence(:title) { |n| "セクション #{n}" }
    sequence(:position) { |n| n }
  end
end
