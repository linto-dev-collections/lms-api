class NotificationPreference::ChannelSettings
  include StoreModel::Model

  attribute :course_approved, :boolean, default: true
  attribute :course_rejected, :boolean, default: true
  attribute :new_enrollment, :boolean, default: true
  attribute :enrollment_completed, :boolean, default: true
  attribute :certificate_issued, :boolean, default: true
  attribute :new_review, :boolean, default: true
end
