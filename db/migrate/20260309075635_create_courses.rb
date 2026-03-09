class CreateCourses < ActiveRecord::Migration[8.1]
  def change
    create_table :courses do |t|
      t.references :instructor, null: false, foreign_key: { to_table: :users, on_delete: :restrict }
      t.string :title, null: false, limit: 200
      t.text :description, null: false
      t.string :category, null: false, limit: 100
      t.string :difficulty, null: false, limit: 20
      t.integer :max_enrollment
      t.string :status, null: false, default: "draft", limit: 20
      t.boolean :archived, null: false, default: false

      t.timestamps
    end

    add_index :courses, [ :status, :created_at ], order: { created_at: :desc },
              name: "index_courses_on_status_and_created_at"
    add_index :courses, [ :status, :category ],
              name: "index_courses_on_status_and_category"
    add_index :courses, [ :status, :difficulty ],
              name: "index_courses_on_status_and_difficulty"
    add_index :courses, [ :instructor_id, :archived ],
              name: "index_courses_on_instructor_id_and_archived"

    add_check_constraint :courses,
      "difficulty IN ('beginner', 'intermediate', 'advanced')",
      name: "chk_courses_difficulty"
    add_check_constraint :courses,
      "status IN ('draft', 'under_review', 'published', 'rejected')",
      name: "chk_courses_status"
    add_check_constraint :courses,
      "max_enrollment > 0",
      name: "chk_courses_max_enrollment"
  end
end
