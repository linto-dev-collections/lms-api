# app/configs/platform_config.rb
class PlatformConfig < ApplicationConfig
  attr_config(
    max_enrollment_per_course: 100,
    review_min_rating: 1,
    review_max_rating: 5,
    allow_anonymous_reviews: true,
    pagination_default_per_page: 20,
    pagination_max_per_page: 50
  )
end
