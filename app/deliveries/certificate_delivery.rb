class CertificateDelivery < ApplicationDelivery
  private

  def recipient
    params[:certificate]&.enrollment&.user
  end
end
