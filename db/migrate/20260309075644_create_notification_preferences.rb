class CreateNotificationPreferences < ActiveRecord::Migration[8.1]
  def change
    create_table :notification_preferences do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }, index: { unique: true }
      t.jsonb :preferences, null: false, default: {
        "in_app" => {
          "course_approved" => true,
          "course_rejected" => true,
          "new_enrollment" => true,
          "enrollment_created" => true,
          "certificate_issued" => true,
          "new_review" => true
        },
        "email" => {
          "course_approved" => false,
          "course_rejected" => false,
          "new_enrollment" => false,
          "enrollment_created" => false,
          "certificate_issued" => false,
          "new_review" => false
        }
      }

      t.timestamps
    end
  end
end
