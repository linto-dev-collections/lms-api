class User < ApplicationRecord
  include EmailVerifiable

  has_secure_password

  # Associations
  has_many :courses, foreign_key: :instructor_id, inverse_of: :instructor, dependent: :restrict_with_error
  has_many :enrollments, dependent: :destroy
  has_many :enrolled_courses, through: :enrollments, source: :course
  has_many :reviews, dependent: :destroy
  has_many :refresh_tokens, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_one :notification_preference, dependent: :destroy

  # Enums
  enum :role, { admin: "admin", instructor: "instructor", student: "student" }, default: :student

  # Validations
  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true, length: { maximum: 100 }
  validates :role, presence: true

  # Normalization
  normalizes :email, with: ->(email) { email.strip.downcase }
end
