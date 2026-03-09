module Enrollments
  class CreateService < ApplicationService
    param :user
    param :course

    def call
      yield validate_user_role
      yield validate_course_published
      yield validate_not_enrolled
      yield check_capacity
      enrollment = yield create_enrollment

      ActiveSupport::Notifications.instrument("created.enrollment", enrollment: enrollment)

      Success(enrollment)
    end

    private

    def validate_user_role
      return Failure(:not_student) unless user.student?

      Success()
    end

    def validate_course_published
      return Failure(:course_not_published) unless course.published?

      Success()
    end

    def validate_not_enrolled
      if Enrollment.exists?(user_id: user.id, course_id: course.id)
        return Failure(:already_enrolled)
      end

      Success()
    end

    def check_capacity
      return Success() if course.max_enrollment.nil?

      current_count = course.enrollments
                            .where.not(status: "suspended")
                            .count
      if current_count >= course.max_enrollment
        Failure(:capacity_exceeded)
      else
        Success()
      end
    end

    def create_enrollment
      enrollment = Enrollment.create!(
        user: user,
        course: course,
        enrolled_at: Time.current
      )
      Success(enrollment)
    rescue ActiveRecord::RecordInvalid
      Failure(:creation_failed)
    end
  end
end
