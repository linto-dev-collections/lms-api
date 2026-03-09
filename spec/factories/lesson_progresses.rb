FactoryBot.define do
  factory :lesson_progress do
    enrollment
    lesson
    status { "not_started" }

    trait :in_progress do
      status { "in_progress" }
    end

    trait :completed do
      status { "completed" }
      completed_at { Time.current }
    end
  end
end
