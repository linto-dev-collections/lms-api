class CreateNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.string :notification_type, null: false, limit: 50
      t.jsonb :params, null: false, default: {}
      t.timestamptz :read_at

      t.timestamptz :created_at, null: false
    end

    remove_index :notifications, :user_id
    add_index :notifications, [ :user_id, :created_at ], order: { created_at: :desc },
              name: "index_notifications_on_user_id_and_created_at"
    add_index :notifications, [ :user_id, :created_at ], order: { created_at: :desc },
              where: "read_at IS NULL",
              name: "index_notifications_unread"

    add_check_constraint :notifications,
      "notification_type IN ('course_approved', 'course_rejected', 'new_enrollment', 'enrollment_completed', 'certificate_issued', 'new_review')",
      name: "chk_notifications_type"
  end
end
