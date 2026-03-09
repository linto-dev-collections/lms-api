# API リクエストメトリクス
ActiveSupport::Notifications.subscribe("process_action.action_controller") do |*, payload|
  next unless payload[:controller].start_with?("Api::")

  controller = payload[:controller].demodulize.underscore
  action = payload[:action]
  status = payload[:status]
  duration = payload[:duration].to_f / 1000.0 # ms → seconds

  Yabeda.api.requests_total.increment(
    { controller: controller, action: action, status: status },
    by: 1
  )

  Yabeda.api.request_duration.measure(
    { controller: controller, action: action },
    duration
  )
end

# ビジネスメトリクス
ActiveSupport::Notifications.subscribe("created.enrollment") do |*, payload|
  enrollment = payload[:enrollment]
  Yabeda.business.enrollments_total.increment(
    { course_id: enrollment.course_id.to_s },
    by: 1
  )
end

ActiveSupport::Notifications.subscribe("completed.enrollment") do |*, payload|
  enrollment = payload[:enrollment]
  Yabeda.business.course_completions_total.increment(
    { course_id: enrollment.course_id.to_s },
    by: 1
  )
end
