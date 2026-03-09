class CourseSerializer
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
end
