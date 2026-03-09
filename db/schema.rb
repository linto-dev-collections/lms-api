# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_03_09_075644) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "certificates", force: :cascade do |t|
    t.string "certificate_number", limit: 50, null: false
    t.datetime "created_at", null: false
    t.bigint "enrollment_id", null: false
    t.datetime "issued_at", precision: nil
    t.string "status", limit: 20, default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index ["certificate_number"], name: "index_certificates_on_certificate_number", unique: true
    t.index ["enrollment_id"], name: "index_certificates_on_enrollment_id", unique: true
    t.check_constraint "status::text = ANY (ARRAY['pending'::character varying::text, 'issued'::character varying::text, 'revoked'::character varying::text])", name: "chk_certificates_status"
  end

  create_table "courses", force: :cascade do |t|
    t.boolean "archived", default: false, null: false
    t.string "category", limit: 100, null: false
    t.datetime "created_at", null: false
    t.text "description", null: false
    t.string "difficulty", limit: 20, null: false
    t.bigint "instructor_id", null: false
    t.integer "max_enrollment"
    t.string "status", limit: 20, default: "draft", null: false
    t.string "title", limit: 200, null: false
    t.datetime "updated_at", null: false
    t.index ["instructor_id", "archived"], name: "index_courses_on_instructor_id_and_archived"
    t.index ["instructor_id"], name: "index_courses_on_instructor_id"
    t.index ["status", "category"], name: "index_courses_on_status_and_category"
    t.index ["status", "created_at"], name: "index_courses_on_status_and_created_at", order: { created_at: :desc }
    t.index ["status", "difficulty"], name: "index_courses_on_status_and_difficulty"
    t.check_constraint "difficulty::text = ANY (ARRAY['beginner'::character varying::text, 'intermediate'::character varying::text, 'advanced'::character varying::text])", name: "chk_courses_difficulty"
    t.check_constraint "max_enrollment > 0", name: "chk_courses_max_enrollment"
    t.check_constraint "status::text = ANY (ARRAY['draft'::character varying::text, 'under_review'::character varying::text, 'published'::character varying::text, 'rejected'::character varying::text])", name: "chk_courses_status"
  end

  create_table "enrollments", force: :cascade do |t|
    t.datetime "completed_at", precision: nil
    t.bigint "course_id", null: false
    t.datetime "created_at", null: false
    t.datetime "enrolled_at", precision: nil, null: false
    t.string "status", limit: 20, default: "pending", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["course_id", "status"], name: "index_enrollments_on_course_id_and_status"
    t.index ["course_id"], name: "index_enrollments_on_course_id"
    t.index ["user_id", "course_id"], name: "index_enrollments_on_user_id_and_course_id", unique: true
    t.index ["user_id", "status"], name: "index_enrollments_on_user_id_and_status"
    t.check_constraint "status::text = ANY (ARRAY['pending'::character varying::text, 'active'::character varying::text, 'completed'::character varying::text, 'suspended'::character varying::text])", name: "chk_enrollments_status"
  end

  create_table "lesson_progresses", force: :cascade do |t|
    t.datetime "completed_at", precision: nil
    t.datetime "created_at", null: false
    t.bigint "enrollment_id", null: false
    t.bigint "lesson_id", null: false
    t.string "status", limit: 20, default: "not_started", null: false
    t.datetime "updated_at", null: false
    t.index ["enrollment_id", "lesson_id"], name: "index_lesson_progresses_on_enrollment_and_lesson", unique: true
    t.index ["enrollment_id"], name: "index_lesson_progresses_completed", where: "((status)::text = 'completed'::text)"
    t.index ["lesson_id"], name: "index_lesson_progresses_on_lesson_id"
    t.check_constraint "status::text = ANY (ARRAY['not_started'::character varying::text, 'in_progress'::character varying::text, 'completed'::character varying::text])", name: "chk_lesson_progresses_status"
  end

  create_table "lessons", force: :cascade do |t|
    t.text "content_body"
    t.string "content_type", limit: 10, null: false
    t.datetime "created_at", null: false
    t.integer "duration_minutes", default: 0, null: false
    t.integer "position", default: 0, null: false
    t.bigint "section_id", null: false
    t.string "title", limit: 200, null: false
    t.datetime "updated_at", null: false
    t.index ["section_id", "position"], name: "index_lessons_on_section_id_and_position"
    t.check_constraint "\"position\" >= 0", name: "chk_lessons_position"
    t.check_constraint "content_type::text = ANY (ARRAY['text'::character varying::text, 'video'::character varying::text, 'quiz'::character varying::text])", name: "chk_lessons_content_type"
    t.check_constraint "duration_minutes >= 0", name: "chk_lessons_duration"
  end

  create_table "notification_preferences", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.jsonb "preferences", default: {"email" => {"new_review" => false, "new_enrollment" => false, "course_approved" => false, "course_rejected" => false, "certificate_issued" => false, "enrollment_completed" => false}, "in_app" => {"new_review" => true, "new_enrollment" => true, "course_approved" => true, "course_rejected" => true, "certificate_issued" => true, "enrollment_completed" => true}}, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_notification_preferences_on_user_id", unique: true
  end

  create_table "notifications", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.string "notification_type", limit: 50, null: false
    t.jsonb "params", default: {}, null: false
    t.datetime "read_at", precision: nil
    t.bigint "user_id", null: false
    t.index ["user_id", "created_at"], name: "index_notifications_on_user_id_and_created_at", order: { created_at: :desc }
    t.index ["user_id", "created_at"], name: "index_notifications_unread", order: { created_at: :desc }, where: "(read_at IS NULL)"
    t.check_constraint "notification_type::text = ANY (ARRAY['course_approved'::character varying::text, 'course_rejected'::character varying::text, 'new_enrollment'::character varying::text, 'enrollment_completed'::character varying::text, 'certificate_issued'::character varying::text, 'new_review'::character varying::text])", name: "chk_notifications_type"
  end

  create_table "refresh_tokens", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.datetime "expires_at", precision: nil, null: false
    t.string "jti", limit: 255, null: false
    t.datetime "revoked_at", precision: nil
    t.string "token_digest", limit: 255, null: false
    t.bigint "user_id", null: false
    t.index ["jti"], name: "index_refresh_tokens_on_jti", unique: true
    t.index ["token_digest"], name: "index_refresh_tokens_on_token_digest", unique: true
    t.index ["user_id"], name: "index_refresh_tokens_active", where: "(revoked_at IS NULL)"
    t.index ["user_id"], name: "index_refresh_tokens_on_user_id"
  end

  create_table "reviews", force: :cascade do |t|
    t.boolean "anonymous", default: false, null: false
    t.text "comment"
    t.bigint "course_id", null: false
    t.datetime "created_at", null: false
    t.integer "rating", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["course_id", "created_at"], name: "index_reviews_on_course_id_and_created_at", order: { created_at: :desc }
    t.index ["course_id", "rating"], name: "index_reviews_on_course_id_and_rating"
    t.index ["user_id", "course_id"], name: "index_reviews_on_user_id_and_course_id", unique: true
    t.check_constraint "rating >= 1 AND rating <= 5", name: "chk_reviews_rating"
  end

  create_table "sections", force: :cascade do |t|
    t.bigint "course_id", null: false
    t.datetime "created_at", null: false
    t.integer "position", default: 0, null: false
    t.string "title", limit: 200, null: false
    t.datetime "updated_at", null: false
    t.index ["course_id", "position"], name: "index_sections_on_course_id_and_position"
    t.check_constraint "\"position\" >= 0", name: "chk_sections_position"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", limit: 255, null: false
    t.string "name", limit: 100, null: false
    t.string "password_digest", limit: 255, null: false
    t.string "role", limit: 20, default: "student", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["role"], name: "index_users_on_role"
    t.check_constraint "role::text = ANY (ARRAY['admin'::character varying::text, 'instructor'::character varying::text, 'student'::character varying::text])", name: "chk_users_role"
  end

  add_foreign_key "certificates", "enrollments", on_delete: :restrict
  add_foreign_key "courses", "users", column: "instructor_id", on_delete: :restrict
  add_foreign_key "enrollments", "courses", on_delete: :restrict
  add_foreign_key "enrollments", "users", on_delete: :cascade
  add_foreign_key "lesson_progresses", "enrollments", on_delete: :cascade
  add_foreign_key "lesson_progresses", "lessons", on_delete: :cascade
  add_foreign_key "lessons", "sections", on_delete: :cascade
  add_foreign_key "notification_preferences", "users", on_delete: :cascade
  add_foreign_key "notifications", "users", on_delete: :cascade
  add_foreign_key "refresh_tokens", "users", on_delete: :cascade
  add_foreign_key "reviews", "courses", on_delete: :cascade
  add_foreign_key "reviews", "users", on_delete: :cascade
  add_foreign_key "sections", "courses", on_delete: :cascade
end
