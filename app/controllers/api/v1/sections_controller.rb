module Api
  module V1
    class SectionsController < BaseController
      before_action :set_course, only: [ :index, :create ]
      before_action :set_section, only: [ :update, :destroy ]

      # GET /api/v1/courses/:course_id/sections
      def index
        sections = @course.sections.includes(:lessons).order(:position)
        render json: {
          sections: sections.map { |s| serialize(s, with: SectionSerializer) }
        }
      end

      # POST /api/v1/courses/:course_id/sections
      def create
        section = @course.sections.build(section_params)
        authorize! section, with: SectionPolicy

        if section.save
          render json: serialize(section, with: SectionSerializer), status: :created
        else
          render_validation_errors(section)
        end
      end

      # PATCH /api/v1/sections/:id
      def update
        authorize! @section, with: SectionPolicy
        if @section.update(section_params)
          render json: serialize(@section, with: SectionSerializer)
        else
          render_validation_errors(@section)
        end
      end

      # DELETE /api/v1/sections/:id
      def destroy
        authorize! @section, with: SectionPolicy
        @section.destroy!
        head :no_content
      end

      private

      def set_course
        @course = Course.find(params[:course_id])
      end

      def set_section
        @section = Section.find(params[:id])
      end

      def section_params
        params.expect(section: [ :title, :position ])
      end
    end
  end
end
