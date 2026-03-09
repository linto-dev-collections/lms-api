FactoryBot.define do
  factory :course do
    association :instructor, factory: [ :user, :instructor ]
    sequence(:title) { |n| "テストコース #{n}" }
    description { "テストコースの説明文です" }
    category { "programming" }
    difficulty { "beginner" }
    status { "draft" }
    archived { false }

    trait :published do
      status { "published" }
    end

    trait :under_review do
      status { "under_review" }
    end

    trait :rejected do
      status { "rejected" }
    end

    trait :archived do
      archived { true }
    end

    trait :with_content do
      after(:create) do |course|
        section = create(:section, course: course)
        create(:lesson, section: section)
      end
    end
  end
end
