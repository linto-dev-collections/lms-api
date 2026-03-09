class Enrollment::FilterQuery
  def initialize(relation = Enrollment.all)
    @relation = relation
  end

  def resolve(params)
    @relation
      .then { |r| filter_by_course(r, params[:course_id]) }
      .then { |r| filter_by_status(r, params[:status]) }
  end

  private

  def filter_by_course(relation, course_id)
    return relation if course_id.blank?

    relation.where(course_id: course_id)
  end

  def filter_by_status(relation, status)
    return relation if status.blank?

    relation.where(status: status)
  end
end
