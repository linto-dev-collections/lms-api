# API リクエストの構造化ログ
ActiveSupport::Notifications.subscribe("process_action.action_controller") do |*, payload|
  next unless payload[:controller].start_with?("Api::")

  Rails.logger.info({
    event: "api_request",
    controller: payload[:controller],
    action: payload[:action],
    status: payload[:status],
    duration_ms: payload[:duration]&.round(2),
    db_runtime_ms: payload[:db_runtime]&.round(2)
  }.to_json)
end
