class Course::TrendingQuery
  def initialize(relation = Course.published)
    @relation = relation
  end

  # 直近30日の受講登録数でランキング
  def resolve(limit: 10)
    @relation
      .left_joins(:enrollments)
      .where(enrollments: { created_at: 30.days.ago.. })
      .or(@relation.left_joins(:enrollments).where(enrollments: { id: nil }))
      .group(:id)
      .order("COUNT(enrollments.id) DESC")
      .limit(limit)
  end
end
