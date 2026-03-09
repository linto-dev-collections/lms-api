source "https://rubygems.org"

gem "rails", "~> 8.1"
gem "pg", "~> 1.5"
gem "puma", ">= 5"
gem "solid_queue", "~> 1.1"
gem "solid_cache", "~> 1.0"
gem "bcrypt", "~> 3.1"
gem "bootsnap", require: false

# Authentication
gem "jwt", "~> 3.1"

# Serialization
gem "alba", "~> 3.9"

# Authorization
gem "action_policy", "~> 0.7"

# State Machine
gem "aasm", "~> 5.5"

# Service Object
gem "dry-initializer", "~> 3.2"
gem "dry-monads", "~> 1.9"

# Notification
gem "active_delivery", "~> 1.2"

# Configuration
gem "anyway_config", "~> 2.8"

# Value Object (JSONB)
gem "store_model", "~> 4.0"

# Pagination
gem "pagy", "~> 43.0"

# Metrics
gem "yabeda", "~> 0.14"
gem "yabeda-rails", "~> 0.10"

# API Documentation
gem "rswag-api"
gem "rswag-ui"

group :development do
  gem "rubocop-rails-omakase", require: false
  gem "brakeman", require: false
  gem "bundler-audit", require: false
end

group :development, :test do
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "rspec-rails", "~> 8.0"
  gem "factory_bot_rails", "~> 6.5"
  gem "rswag-specs"
end

group :test do
  gem "shoulda-matchers", "~> 7.0"
end
