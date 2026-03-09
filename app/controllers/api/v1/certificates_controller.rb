module Api
  module V1
    class CertificatesController < BaseController
      skip_before_action :authenticate_user!, only: [ :show ]

      # GET /api/v1/certificates
      def index
        certificates = Certificate.joins(:enrollment)
                                  .where(enrollments: { user_id: current_user.id })
                                  .includes(enrollment: [ :course, :user ])
        render json: {
          certificates: certificates.map { |c| serialize(c, with: CertificateSerializer) }
        }
      end

      # GET /api/v1/certificates/:certificate_number
      def show
        certificate = Certificate.find_by!(certificate_number: params[:certificate_number])
        render json: serialize(certificate, with: CertificateSerializer)
      end
    end
  end
end
