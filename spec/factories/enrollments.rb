FactoryBot.define do
  factory :enrollment do
    user { association :user, :student }
    association :course, :published
    status { "pending" }
    enrolled_at { Time.current }

    trait :active do
      status { "active" }
    end

    trait :completed do
      status { "completed" }
      completed_at { Time.current }
    end

    trait :suspended do
      status { "suspended" }
    end
  end
end
