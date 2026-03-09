class EnrollmentSerializer
  include Alba::Resource

  root_key :enrollment

  attributes :id, :status, :enrolled_at, :completed_at, :created_at, :updated_at

  attribute :user do |enrollment|
    {
      id: enrollment.user.id,
      name: enrollment.user.name
    }
  end

  attribute :course do |enrollment|
    {
      id: enrollment.course.id,
      title: enrollment.course.title
    }
  end

  attribute :progress do |enrollment|
    total = enrollment.course.lessons.count
    completed = enrollment.lesson_progresses.where(status: "completed").count
    {
      total_lessons: total,
      completed_lessons: completed,
      percentage: total.positive? ? (completed.to_f / total * 100).round(1) : 0.0
    }
  end
end
