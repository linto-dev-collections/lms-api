FactoryBot.define do
  factory :certificate do
    enrollment { association :enrollment, :completed }
    status { "pending" }
    sequence(:certificate_number) { |n| "CERT-#{n.to_s.rjust(8, '0')}" }

    trait :issued do
      status { "issued" }
      issued_at { Time.current }
    end

    trait :revoked do
      status { "revoked" }
      issued_at { 1.day.ago }
    end
  end
end
