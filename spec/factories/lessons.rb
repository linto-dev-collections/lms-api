FactoryBot.define do
  factory :lesson do
    section
    sequence(:title) { |n| "レッスン #{n}" }
    content_type { "text" }
    content_body { "レッスンのコンテンツです" }
    duration_minutes { 30 }
    sequence(:position) { |n| n }
  end
end
