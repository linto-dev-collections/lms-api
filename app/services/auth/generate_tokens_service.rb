module Auth
  class GenerateTokensService < ApplicationService
    param :user

    def call
      jti = SecureRandom.uuid
      refresh_token_raw = SecureRandom.hex(32)
      refresh_token_digest = Digest::SHA256.hexdigest(refresh_token_raw)

      access_token = JsonWebToken.encode({
        sub: user.id,
        role: user.role,
        jti: jti
      })

      RefreshToken.create!(
        user: user,
        token_digest: refresh_token_digest,
        jti: jti,
        expires_at: AuthConfig.instance.refresh_token_expiry.seconds.from_now
      )

      Success({
        access_token: access_token,
        refresh_token: refresh_token_raw,
        token_type: "Bearer",
        expires_in: AuthConfig.instance.access_token_expiry
      })
    end
  end
end
