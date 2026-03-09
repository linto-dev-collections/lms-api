class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email, null: false, limit: 255
      t.string :password_digest, null: false, limit: 255
      t.string :name, null: false, limit: 100
      t.string :role, null: false, default: "student", limit: 20

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :role

    add_check_constraint :users,
      "role IN ('admin', 'instructor', 'student')",
      name: "chk_users_role"
  end
end
