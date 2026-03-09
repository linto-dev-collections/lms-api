class CourseInstructorSerializer
  include Alba::Resource

  root_key :course

  attributes :id, :title, :description, :category, :difficulty,
             :max_enrollment, :status, :archived, :created_at, :updated_at

  attribute :enrollment_count do |course|
    course.enrollments.count
  end

  attribute :active_enrollment_count do |course|
    course.enrollments.where(status: :active).count
  end

  attribute :completed_enrollment_count do |course|
    course.enrollments.where(status: :completed).count
  end

  attribute :average_rating do |course|
    course.reviews.average(:rating)&.round(2)
  end

  attribute :review_count do |course|
    course.reviews.count
  end
end
