module Auth
  class RevokeRefreshTokenService < ApplicationService
    param :refresh_token_raw

    def call
      token_digest = Digest::SHA256.hexdigest(refresh_token_raw)
      refresh_token = RefreshToken.find_by(token_digest: token_digest)

      return Failure(:token_not_found) unless refresh_token

      refresh_token.revoke!
      Success(true)
    end
  end
end
