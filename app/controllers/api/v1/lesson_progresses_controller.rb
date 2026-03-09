module Api
  module V1
    class LessonProgressesController < BaseController
      # POST /api/v1/lessons/:lesson_id/progress
      def create
        lesson = Lesson.find(params[:id])
        enrollment = current_user.enrollments.find_by!(course_id: lesson.section.course_id)

        authorize! enrollment, with: EnrollmentPolicy, to: :progress?

        progress = enrollment.lesson_progresses.find_or_initialize_by(lesson: lesson)
        progress.status = progress_params[:status]
        progress.completed_at = Time.current if progress.completed?

        if progress.save
          if progress.completed? && enrollment.may_complete?
            Enrollments::CompleteService.call(enrollment)
          end

          render json: serialize(progress, with: LessonProgressSerializer),
                 status: progress.previously_new_record? ? :created : :ok
        else
          render_validation_errors(progress)
        end
      end

      private

      def progress_params
        params.expect(progress: [ :status ])
      end
    end
  end
end
