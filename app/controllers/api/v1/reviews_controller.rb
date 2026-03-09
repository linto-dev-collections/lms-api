module Api
  module V1
    class ReviewsController < BaseController
      skip_before_action :authenticate_user!, only: [ :index ]
      before_action :set_course, only: [ :index, :create ]
      before_action :set_review, only: [ :update, :destroy ]

      # GET /api/v1/courses/:course_id/reviews
      def index
        reviews = @course.reviews.includes(:user).newest_first
        pagy, records = pagy(:offset, reviews)

        render json: {
          reviews: records.map { |r| serialize(r, with: ReviewSerializer) },
          meta: pagy_metadata(pagy)
        }
      end

      # POST /api/v1/courses/:course_id/reviews
      def create
        form = Reviews::CreateForm.new(review_params)
        unless form.valid?
          return render_validation_errors(form)
        end

        # 受講修了者のみレビュー可能
        enrollment = current_user.enrollments.find_by(course_id: @course.id, status: "completed")
        unless enrollment
          return render_error("受講を修了したコースのみレビューできます",
                             status: :forbidden, code: "not_completed")
        end

        review = @course.reviews.build(
          user: current_user,
          rating: form.rating,
          comment: form.comment,
          anonymous: form.anonymous
        )

        if review.save
          ActiveSupport::Notifications.instrument("created.review", review: review)
          render json: serialize(review, with: ReviewSerializer), status: :created
        else
          render_validation_errors(review)
        end
      end

      # PATCH /api/v1/reviews/:id
      def update
        authorize! @review, with: ReviewPolicy
        if @review.update(review_params)
          render json: serialize(@review, with: ReviewSerializer)
        else
          render_validation_errors(@review)
        end
      end

      # DELETE /api/v1/reviews/:id
      def destroy
        authorize! @review, with: ReviewPolicy
        @review.destroy!
        head :no_content
      end

      private

      def set_course
        @course = Course.find(params[:course_id])
      end

      def set_review
        @review = Review.find(params[:id])
      end

      def review_params
        params.expect(review: [ :rating, :comment, :anonymous ])
      end
    end
  end
end
