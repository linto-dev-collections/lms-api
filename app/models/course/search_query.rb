class Course::SearchQuery
  def initialize(relation = Course.all)
    @relation = relation
  end

  def resolve(params)
    @relation
      .then { |r| filter_by_keyword(r, params[:q]) }
      .then { |r| filter_by_category(r, params[:category]) }
      .then { |r| filter_by_difficulty(r, params[:difficulty]) }
      .then { |r| filter_by_min_rating(r, params[:min_rating]) }
      .then { |r| apply_sort(r, params[:sort]) }
  end

  private

  def filter_by_keyword(relation, keyword)
    return relation if keyword.blank?

    sanitized = ActiveRecord::Base.sanitize_sql_like(keyword)
    relation.where("title ILIKE :q OR description ILIKE :q", q: "%#{sanitized}%")
  end

  def filter_by_category(relation, category)
    return relation if category.blank?

    relation.where(category: category)
  end

  def filter_by_difficulty(relation, difficulty)
    return relation if difficulty.blank?

    relation.where(difficulty: difficulty)
  end

  def filter_by_min_rating(relation, min_rating)
    return relation if min_rating.blank?

    course_ids = Review.group(:course_id)
                       .having("AVG(rating) >= ?", min_rating.to_f)
                       .pluck(:course_id)
    relation.where(id: course_ids)
  end

  def apply_sort(relation, sort)
    case sort
    when "newest"
      relation.order(created_at: :desc)
    when "popular"
      relation.left_joins(:enrollments)
              .group(:id)
              .order("COUNT(enrollments.id) DESC")
    when "rating"
      relation.left_joins(:reviews)
              .group(:id)
              .order("AVG(reviews.rating) DESC NULLS LAST")
    else
      relation.order(created_at: :desc)
    end
  end
end
