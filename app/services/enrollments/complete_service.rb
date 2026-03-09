module Enrollments
  class CompleteService < ApplicationService
    param :enrollment

    def call
      yield validate_completable
      yield complete_enrollment
      certificate = yield issue_certificate

      ActiveSupport::Notifications.instrument("completed.enrollment", enrollment: enrollment)
      ActiveSupport::Notifications.instrument("issued.certificate", certificate: certificate)

      Success(certificate)
    end

    private

    def validate_completable
      unless enrollment.may_complete?
        return Failure(:cannot_complete)
      end

      Success()
    end

    def complete_enrollment
      enrollment.complete!
      enrollment.update!(completed_at: Time.current)
      Success()
    end

    def issue_certificate
      Certificates::IssueService.call(enrollment)
    end
  end
end
