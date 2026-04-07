# app/configs/auth_config.rb
class AuthConfig < ApplicationConfig
  attr_config(
    access_token_expiry: 900,
    refresh_token_expiry: 604_800,
    jwt_algorithm: "HS256",
    jwt_secret_key: nil,
    refresh_token_reuse_detection: true,
    email_verification_expiry: 86_400,
    email_verification_resend_interval: 60
  )

  required :jwt_secret_key

  on_load :validate_jwt_secret_key_strength

  private

  def validate_jwt_secret_key_strength
    return unless jwt_secret_key

    if jwt_secret_key.bytesize < 32
      raise_validation_error "jwt_secret_key must be at least 32 bytes (256 bits) for HS256"
    end
  end
end
