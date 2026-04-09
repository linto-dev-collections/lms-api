Resend.api_key = ENV["RESEND_API_KEY"]

if Rails.env.production? && Resend.api_key.blank?
  # Rake タスク（db:prepare 等）では Rake 定数が定義される
  # rails runner では呼び出しスタックに runner_command.rb が含まれる
  # Web サーバー（Puma）起動時のみ raise する
  running_as_runner = caller_locations.any? { |l| l.path.to_s.include?("runner_command") }
  raise "RESEND_API_KEY is required in production" unless defined?(Rake) || running_as_runner
end
