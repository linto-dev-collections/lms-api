class LessonSerializer
  include Alba::Resource

  root_key :lesson

  attributes :id, :title, :content_type, :content_body,
             :duration_minutes, :position, :created_at, :updated_at

  attribute :section_id do |lesson|
    lesson.section_id
  end
end
