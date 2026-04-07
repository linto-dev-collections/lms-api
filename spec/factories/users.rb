FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    name { "テストユーザー" }
    password { "password123" }
    role { "student" }
    email_verified_at { Time.current }

    trait :unverified do
      email_verified_at { nil }
    end

    trait :admin do
      role { "admin" }
      name { "管理者" }
    end

    trait :instructor do
      role { "instructor" }
      name { "講師" }
    end

    trait :student do
      role { "student" }
      name { "受講者" }
    end
  end
end
