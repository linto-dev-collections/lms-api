class CreateEnrollments < ActiveRecord::Migration[8.1]
  def change
    create_table :enrollments do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.references :course, null: false, foreign_key: { on_delete: :restrict }
      t.string :status, null: false, default: "pending", limit: 20
      t.timestamptz :enrolled_at, null: false
      t.timestamptz :completed_at

      t.timestamps
    end

    remove_index :enrollments, :user_id
    remove_index :enrollments, :course_id
    add_index :enrollments, [ :user_id, :course_id ], unique: true
    add_index :enrollments, :course_id
    add_index :enrollments, [ :user_id, :status ]
    add_index :enrollments, [ :course_id, :status ]

    add_check_constraint :enrollments,
      "status IN ('pending', 'active', 'completed', 'suspended')",
      name: "chk_enrollments_status"
  end
end
