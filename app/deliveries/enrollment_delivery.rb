class EnrollmentDelivery < ApplicationDelivery
  private

  def recipient
    case notification_name.to_sym
    when :new_enrollment
      params[:enrollment]&.course&.instructor
    when :enrollment_created
      params[:enrollment]&.user
    when :new_review
      params[:review]&.course&.instructor
    end
  end
end
