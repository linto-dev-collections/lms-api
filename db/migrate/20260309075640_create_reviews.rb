class CreateReviews < ActiveRecord::Migration[8.1]
  def change
    create_table :reviews do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.references :course, null: false, foreign_key: { on_delete: :cascade }
      t.integer :rating, null: false
      t.text :comment
      t.boolean :anonymous, null: false, default: false

      t.timestamps
    end

    remove_index :reviews, :user_id
    remove_index :reviews, :course_id
    add_index :reviews, [ :user_id, :course_id ], unique: true
    add_index :reviews, [ :course_id, :created_at ], order: { created_at: :desc },
              name: "index_reviews_on_course_id_and_created_at"
    add_index :reviews, [ :course_id, :rating ]

    add_check_constraint :reviews,
      "rating BETWEEN 1 AND 5",
      name: "chk_reviews_rating"
  end
end
