module Api
  module V1
    class EnrollmentsController < BaseController
      before_action :set_enrollment, only: [ :show, :activate, :suspend, :resume, :progress ]
      before_action :set_course, only: [ :create ]

      # POST /api/v1/courses/:course_id/enrollments
      def create
        case Enrollments::CreateService.call(current_user, @course)
        in Dry::Monads::Success(enrollment)
          render json: serialize(enrollment, with: EnrollmentSerializer), status: :created
        in Dry::Monads::Failure(:not_student)
          render_error("受講者ロールのユーザーのみ受講登録できます", status: :forbidden, code: "forbidden")
        in Dry::Monads::Failure(:course_not_published)
          render_error("公開済みコースのみ受講登録できます", status: :unprocessable_entity, code: "course_not_published")
        in Dry::Monads::Failure(:already_enrolled)
          render_error("既にこのコースに受講登録済みです", status: :conflict, code: "already_enrolled")
        in Dry::Monads::Failure(:capacity_exceeded)
          render_error("定員に達しています", status: :unprocessable_entity, code: "capacity_exceeded")
        in Dry::Monads::Failure(_)
          render_error("受講登録に失敗しました", status: :unprocessable_entity, code: "enrollment_failed")
        end
      end

      # GET /api/v1/enrollments
      def index
        enrollments = current_user.enrollments.includes(:course)
        pagy, records = pagy(:offset, enrollments.order(created_at: :desc))

        render json: {
          enrollments: records.map { |e| serialize(e, with: EnrollmentSerializer) },
          meta: pagy_metadata(pagy)
        }
      end

      # GET /api/v1/enrollments/:id
      def show
        authorize! @enrollment, with: EnrollmentPolicy
        render json: serialize(@enrollment, with: EnrollmentSerializer)
      end

      # POST /api/v1/enrollments/:id/activate
      def activate
        authorize! @enrollment, with: EnrollmentPolicy
        @enrollment.activate!
        render json: serialize(@enrollment, with: EnrollmentSerializer)
      end

      # POST /api/v1/enrollments/:id/suspend
      def suspend
        authorize! @enrollment, with: EnrollmentPolicy
        @enrollment.suspend!
        render json: serialize(@enrollment, with: EnrollmentSerializer)
      end

      # POST /api/v1/enrollments/:id/resume
      def resume
        authorize! @enrollment, with: EnrollmentPolicy
        @enrollment.resume!
        render json: serialize(@enrollment, with: EnrollmentSerializer)
      end

      # GET /api/v1/enrollments/:id/progress
      def progress
        authorize! @enrollment, with: EnrollmentPolicy
        summary = Enrollment::ProgressSummaryQuery.new(@enrollment).resolve
        progresses = @enrollment.lesson_progresses.includes(:lesson)

        render json: {
          summary: summary,
          lesson_progresses: progresses.map { |lp| serialize(lp, with: LessonProgressSerializer) }
        }
      end

      private

      def set_enrollment
        @enrollment = Enrollment.find(params[:id])
      end

      def set_course
        @course = Course.find(params[:course_id])
      end
    end
  end
end
