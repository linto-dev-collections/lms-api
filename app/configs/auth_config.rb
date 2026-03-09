# app/configs/auth_config.rb
class AuthConfig < ApplicationConfig
  attr_config(
    access_token_expiry: 900,
    refresh_token_expiry: 604_800,
    jwt_algorithm: "HS256",
    jwt_secret_key: nil,
    refresh_token_reuse_detection: true
  )
end
