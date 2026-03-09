Yabeda.configure do
  group :api do
    counter :requests_total,
            comment: "API リクエスト数",
            tags: [ :controller, :action, :status ]

    histogram :request_duration,
              comment: "API レスポンスタイム",
              unit: :seconds,
              tags: [ :controller, :action ],
              buckets: [ 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2.5, 5 ]
  end

  group :business do
    counter :enrollments_total,
            comment: "受講登録数",
            tags: [ :course_id ]

    counter :course_completions_total,
            comment: "コース修了数",
            tags: [ :course_id ]

    gauge :active_enrollments,
          comment: "アクティブ受講数"
  end
end
