class CourseDetailSerializer
  include Alba::Resource

  root_key :course

  attributes :id, :title, :description, :category, :difficulty,
             :max_enrollment, :status, :archived, :created_at, :updated_at

  attribute :instructor do |course|
    {
      id: course.instructor.id,
      name: course.instructor.name
    }
  end

  attribute :enrollment_count do |course|
    course.enrollments.count
  end

  attribute :average_rating do |course|
    course.reviews.average(:rating)&.round(2)
  end

  attribute :sections do |course|
    course.sections.includes(:lessons).order(:position).map do |section|
      {
        id: section.id,
        title: section.title,
        position: section.position,
        lessons: section.lessons.order(:position).map do |lesson|
          {
            id: lesson.id,
            title: lesson.title,
            content_type: lesson.content_type,
            duration_minutes: lesson.duration_minutes,
            position: lesson.position
          }
        end
      }
    end
  end

  attribute :total_duration_minutes do |course|
    course.lessons.sum(:duration_minutes)
  end

  attribute :total_lessons do |course|
    course.lessons.count
  end
end
