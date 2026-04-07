class CourseDelivery < ApplicationDelivery
  private

  def recipient
    params[:course]&.instructor
  end
end
