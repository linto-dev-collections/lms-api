FactoryBot.define do
  factory :notification do
    user
    notification_type { "new_enrollment" }
    params { { course_title: "テストコース" } }

    trait :read do
      read_at { Time.current }
    end

    trait :unread do
      read_at { nil }
    end
  end
end
