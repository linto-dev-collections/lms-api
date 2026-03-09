FactoryBot.define do
  factory :refresh_token do
    user
    sequence(:token_digest) { |n| Digest::SHA256.hexdigest("token_#{n}") }
    sequence(:jti) { |n| SecureRandom.uuid }
    expires_at { 7.days.from_now }

    trait :expired do
      expires_at { 1.hour.ago }
    end

    trait :revoked do
      revoked_at { Time.current }
    end
  end
end
