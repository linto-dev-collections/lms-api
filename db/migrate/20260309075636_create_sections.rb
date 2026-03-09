class CreateSections < ActiveRecord::Migration[8.1]
  def change
    create_table :sections do |t|
      t.references :course, null: false, foreign_key: { on_delete: :cascade }
      t.string :title, null: false, limit: 200
      t.integer :position, null: false, default: 0

      t.timestamps
    end

    remove_index :sections, :course_id
    add_index :sections, [ :course_id, :position ]

    add_check_constraint :sections,
      "position >= 0",
      name: "chk_sections_position"
  end
end
