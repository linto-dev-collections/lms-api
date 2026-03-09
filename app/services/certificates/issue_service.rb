module Certificates
  class IssueService < ApplicationService
    param :enrollment

    def call
      yield validate_enrollment_completed
      certificate = yield create_certificate
      yield issue_certificate(certificate)

      Success(certificate)
    end

    private

    def validate_enrollment_completed
      unless enrollment.completed?
        return Failure(:enrollment_not_completed)
      end

      Success()
    end

    def create_certificate
      certificate = Certificate.create!(
        enrollment: enrollment,
        certificate_number: generate_certificate_number
      )
      Success(certificate)
    rescue ActiveRecord::RecordInvalid => e
      if e.message.include?("already")
        Failure(:certificate_already_exists)
      else
        Failure(:certificate_creation_failed)
      end
    end

    def issue_certificate(certificate)
      certificate.issue!
      certificate.update!(issued_at: Time.current)
      Success()
    end

    def generate_certificate_number
      loop do
        number = "CERT-#{SecureRandom.alphanumeric(8).upcase}"
        break number unless Certificate.exists?(certificate_number: number)
      end
    end
  end
end
