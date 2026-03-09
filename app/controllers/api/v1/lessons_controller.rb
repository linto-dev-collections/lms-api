module Api
  module V1
    class LessonsController < BaseController
      before_action :set_section, only: [ :create ]
      before_action :set_lesson, only: [ :show, :update, :destroy ]

      # GET /api/v1/lessons/:id
      def show
        authorize! @lesson, with: LessonPolicy
        render json: serialize(@lesson, with: LessonSerializer)
      end

      # POST /api/v1/sections/:section_id/lessons
      def create
        lesson = @section.lessons.build(lesson_params)
        authorize! @section, with: SectionPolicy, to: :update?

        if lesson.save
          render json: serialize(lesson, with: LessonSerializer), status: :created
        else
          render_validation_errors(lesson)
        end
      end

      # PATCH /api/v1/lessons/:id
      def update
        section = @lesson.section
        authorize! section, with: SectionPolicy, to: :update?

        if @lesson.update(lesson_params)
          render json: serialize(@lesson, with: LessonSerializer)
        else
          render_validation_errors(@lesson)
        end
      end

      # DELETE /api/v1/lessons/:id
      def destroy
        section = @lesson.section
        authorize! section, with: SectionPolicy, to: :destroy?

        @lesson.destroy!
        head :no_content
      end

      private

      def set_section
        @section = Section.find(params[:section_id])
      end

      def set_lesson
        @lesson = Lesson.find(params[:id])
      end

      def lesson_params
        params.expect(lesson: [ :title, :content_type, :content_body, :duration_minutes, :position ])
      end
    end
  end
end
