class ReviewSerializer
  include Alba::Resource

  root_key :review

  attributes :id, :rating, :comment, :anonymous, :created_at, :updated_at

  attribute :user do |review|
    if review.anonymous?
      { id: nil, name: "匿名" }
    else
      { id: review.user.id, name: review.user.name }
    end
  end

  attribute :course do |review|
    {
      id: review.course.id,
      title: review.course.title
    }
  end
end
