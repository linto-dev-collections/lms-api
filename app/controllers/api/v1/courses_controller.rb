module Api
  module V1
    class CoursesController < BaseController
      skip_before_action :authenticate_user!, only: [ :index, :show ]
      before_action :authenticate_user_if_present, only: [ :index, :show ]
      before_action :set_course, only: [
        :show, :update, :destroy,
        :submit_for_review, :approve, :reject, :unpublish,
        :archive, :unarchive
      ]

      # GET /api/v1/courses
      def index
        relation = if current_user
                     authorized_scope(Course.all, with: CoursePolicy)
        else
                     Course.where(status: :published)
        end

        courses = Course::SearchQuery.new(relation).resolve(search_params)
        pagy, records = pagy(:offset, courses)

        serializer = current_user&.instructor? ? CourseInstructorSerializer : CourseSerializer

        render json: {
          courses: records.map { |c| serialize(c, with: serializer) },
          meta: pagy_metadata(pagy)
        }
      end

      # GET /api/v1/courses/:id
      def show
        if current_user
          authorize! @course, with: CoursePolicy
        elsif !@course.published?
          raise ActiveRecord::RecordNotFound
        end

        serializer = if current_user&.instructor? && @course.instructor_id == current_user.id
                       CourseInstructorSerializer
        else
                       CourseDetailSerializer
        end

        render json: serialize(@course, with: serializer)
      end

      # POST /api/v1/courses
      def create
        authorize! Course, with: CoursePolicy

        form = Courses::CreateForm.new(course_params)
        unless form.valid?
          return render_validation_errors(form)
        end

        course = Course.new(form.attributes.merge(instructor: current_user))
        if course.save
          render json: serialize(course, with: CourseInstructorSerializer), status: :created
        else
          render_validation_errors(course)
        end
      end

      # PATCH /api/v1/courses/:id
      def update
        authorize! @course

        form = Courses::UpdateForm.new(course_params)
        unless form.valid?
          return render_validation_errors(form)
        end

        if @course.update(form.attributes_for_update)
          render json: serialize(@course, with: CourseInstructorSerializer)
        else
          render_validation_errors(@course)
        end
      end

      # DELETE /api/v1/courses/:id
      def destroy
        authorize! @course

        @course.destroy!
        head :no_content
      end

      # POST /api/v1/courses/:id/submit_for_review
      def submit_for_review
        authorize! @course
        @course.submit_for_review!
        render json: serialize(@course, with: CourseInstructorSerializer)
      end

      # POST /api/v1/courses/:id/approve
      def approve
        authorize! @course
        @course.approve!
        ActiveSupport::Notifications.instrument("approved.course", course: @course)
        render json: serialize(@course, with: CourseSerializer)
      end

      # POST /api/v1/courses/:id/reject
      def reject
        authorize! @course
        @course.reject!
        ActiveSupport::Notifications.instrument("rejected.course", course: @course, reason: params[:reason])
        render json: serialize(@course, with: CourseSerializer)
      end

      # POST /api/v1/courses/:id/unpublish
      def unpublish
        authorize! @course
        @course.unpublish!
        render json: serialize(@course, with: CourseSerializer)
      end

      # POST /api/v1/courses/:id/archive
      def archive
        authorize! @course
        @course.update!(archived: true)
        render json: serialize(@course, with: CourseSerializer)
      end

      # POST /api/v1/courses/:id/unarchive
      def unarchive
        authorize! @course
        @course.update!(archived: false)
        render json: serialize(@course, with: CourseSerializer)
      end

      private

      def set_course
        @course = Course.find(params[:id])
      end

      def course_params
        params.expect(course: [ :title, :description, :category, :difficulty, :max_enrollment ])
      end

      def search_params
        params.permit(:q, :category, :difficulty, :min_rating, :sort)
      end
    end
  end
end
