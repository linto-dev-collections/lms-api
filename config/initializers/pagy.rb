# config/initializers/pagy.rb
Rails.application.config.after_initialize do
  Pagy::OPTIONS[:limit] = PlatformConfig.instance.pagination_default_per_page
  Pagy::OPTIONS[:client_max_limit] = PlatformConfig.instance.pagination_max_per_page
  Pagy::OPTIONS.freeze
end
