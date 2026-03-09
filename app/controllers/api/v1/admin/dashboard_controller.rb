module Api
  module V1
    module Admin
      class DashboardController < BaseController
        before_action :authorize_admin!

        # GET /api/v1/admin/dashboard
        def show
          render json: {
            dashboard: {
              users: {
                total: User.count,
                by_role: {
                  admin: User.admin.count,
                  instructor: User.instructor.count,
                  student: User.student.count
                }
              },
              courses: {
                total: Course.count,
                by_status: {
                  draft: Course.draft.count,
                  under_review: Course.under_review.count,
                  published: Course.published.count,
                  rejected: Course.rejected.count
                },
                archived: Course.where(archived: true).count
              },
              enrollments: {
                total: Enrollment.count,
                by_status: {
                  pending: Enrollment.where(status: "pending").count,
                  active: Enrollment.where(status: "active").count,
                  completed: Enrollment.where(status: "completed").count,
                  suspended: Enrollment.where(status: "suspended").count
                }
              },
              certificates: {
                total: Certificate.count,
                issued: Certificate.where(status: "issued").count
              },
              reviews: {
                total: Review.count,
                average_rating: Review.average(:rating)&.round(2)
              }
            }
          }
        end

        # GET /api/v1/admin/courses
        def courses
          courses_relation = Course.includes(:instructor)
          pagy, records = pagy(:offset, courses_relation.order(created_at: :desc))

          render json: {
            courses: records.map { |c| serialize(c, with: CourseInstructorSerializer) },
            meta: pagy_metadata(pagy)
          }
        end

        # GET /api/v1/admin/courses/pending_review
        def pending_review
          courses_relation = Course.under_review.includes(:instructor).order(updated_at: :asc)
          pagy, records = pagy(:offset, courses_relation)

          render json: {
            courses: records.map { |c| serialize(c, with: CourseInstructorSerializer) },
            meta: pagy_metadata(pagy)
          }
        end

        private

        def authorize_admin!
          render_error("管理者権限が必要です", status: :forbidden, code: "admin_required") unless current_user.admin?
        end
      end
    end
  end
end
