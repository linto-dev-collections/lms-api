class CreateLessonProgresses < ActiveRecord::Migration[8.1]
  def change
    create_table :lesson_progresses do |t|
      t.references :enrollment, null: false, foreign_key: { on_delete: :cascade }
      t.references :lesson, null: false, foreign_key: { on_delete: :cascade }
      t.string :status, null: false, default: "not_started", limit: 20
      t.timestamptz :completed_at

      t.timestamps
    end

    remove_index :lesson_progresses, :enrollment_id
    remove_index :lesson_progresses, :lesson_id
    add_index :lesson_progresses, [ :enrollment_id, :lesson_id ], unique: true,
              name: "index_lesson_progresses_on_enrollment_and_lesson"
    add_index :lesson_progresses, :lesson_id
    add_index :lesson_progresses, :enrollment_id,
              where: "status = 'completed'",
              name: "index_lesson_progresses_completed"

    add_check_constraint :lesson_progresses,
      "status IN ('not_started', 'in_progress', 'completed')",
      name: "chk_lesson_progresses_status"
  end
end
