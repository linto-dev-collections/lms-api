module Auth
  class RefreshTokensService < ApplicationService
    param :refresh_token_raw

    def call
      token_digest = Digest::SHA256.hexdigest(refresh_token_raw)

      RefreshToken.transaction do
        refresh_token = RefreshToken.lock.find_by(token_digest: token_digest)

        return Failure(:token_not_found) unless refresh_token

        if refresh_token.revoked?
          if AuthConfig.instance.refresh_token_reuse_detection
            refresh_token.user.refresh_tokens.active.update_all(revoked_at: Time.current)
          end
          return Failure(:token_reused)
        end

        return Failure(:token_expired) if refresh_token.expired?

        refresh_token.revoke!

        Auth::GenerateTokensService.call(refresh_token.user)
      end
    end
  end
end
