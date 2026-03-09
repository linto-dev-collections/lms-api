FactoryBot.define do
  factory :review do
    user { association :user, :student }
    course { association :course, :published }
    rating { 4 }
    comment { "素晴らしいコースでした" }
    anonymous { false }
  end
end
