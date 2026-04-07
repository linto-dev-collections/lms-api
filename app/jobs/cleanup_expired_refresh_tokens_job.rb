class CleanupExpiredRefreshTokensJob < ApplicationJob
  queue_as :default

  def perform
    deleted_count = RefreshToken
      .where("expires_at < ? OR revoked_at IS NOT NULL", 1.day.ago)
      .in_batches(of: 1000)
      .delete_all

    Rails.logger.info("CleanupExpiredRefreshTokensJob: deleted #{deleted_count} expired/revoked refresh tokens")
  end
end
