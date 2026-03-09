class Enrollment::ProgressSummaryQuery
  def initialize(enrollment)
    @enrollment = enrollment
  end

  def resolve
    total = @enrollment.course.lessons.count
    completed = @enrollment.lesson_progresses.where(status: "completed").count
    in_progress = @enrollment.lesson_progresses.where(status: "in_progress").count

    {
      total_lessons: total,
      completed_lessons: completed,
      in_progress_lessons: in_progress,
      not_started_lessons: total - completed - in_progress,
      percentage: total.positive? ? (completed.to_f / total * 100).round(1) : 0.0
    }
  end
end
