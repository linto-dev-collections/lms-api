Resend.api_key = ENV["RESEND_API_KEY"]

# Rake タスク（db:prepare 等）や rails runner では RESEND_API_KEY は不要
# Web サーバー（Puma）起動時のみ必須チェックを行う
if Rails.env.production? && Resend.api_key.blank? &&
    !defined?(Rake) && ARGV.first != "runner"
  raise "RESEND_API_KEY is required in production"
end
