class Course::InstructorCoursesQuery
  def initialize(relation = Course.all)
    @relation = relation
  end

  def resolve(instructor_id:, archived: nil)
    result = @relation.where(instructor_id: instructor_id)
    result = result.where(archived: archived) unless archived.nil?
    result.order(updated_at: :desc)
  end
end
