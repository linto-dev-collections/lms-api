class LessonProgressSerializer
  include Alba::Resource

  root_key :lesson_progress

  attributes :id, :status, :completed_at

  attribute :lesson do |progress|
    {
      id: progress.lesson.id,
      title: progress.lesson.title,
      content_type: progress.lesson.content_type
    }
  end
end
