class SectionSerializer
  include Alba::Resource

  root_key :section

  attributes :id, :title, :position, :created_at, :updated_at

  attribute :course_id do |section|
    section.course_id
  end

  attribute :lessons do |section|
    section.lessons.order(:position).map do |lesson|
      {
        id: lesson.id,
        title: lesson.title,
        content_type: lesson.content_type,
        content_body: lesson.content_body,
        duration_minutes: lesson.duration_minutes,
        position: lesson.position
      }
    end
  end
end
