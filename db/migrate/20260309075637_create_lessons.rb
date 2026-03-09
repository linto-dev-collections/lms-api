class CreateLessons < ActiveRecord::Migration[8.1]
  def change
    create_table :lessons do |t|
      t.references :section, null: false, foreign_key: { on_delete: :cascade }
      t.string :title, null: false, limit: 200
      t.string :content_type, null: false, limit: 10
      t.text :content_body
      t.integer :duration_minutes, null: false, default: 0
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    remove_index :lessons, :section_id
    add_index :lessons, [ :section_id, :position ]

    add_check_constraint :lessons,
      "content_type IN ('text', 'video', 'quiz')",
      name: "chk_lessons_content_type"
    add_check_constraint :lessons,
      "duration_minutes >= 0",
      name: "chk_lessons_duration"
    add_check_constraint :lessons,
      "position >= 0",
      name: "chk_lessons_position"
  end
end
