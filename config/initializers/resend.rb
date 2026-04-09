Resend.api_key = ENV["RESEND_API_KEY"]

if Rails.env.production? && Resend.api_key.blank? && !defined?(Rake)
  raise "RESEND_API_KEY is required in production"
end
