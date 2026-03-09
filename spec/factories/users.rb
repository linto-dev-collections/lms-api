FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    name { "テストユーザー" }
    password { "password123" }
    role { "student" }

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
