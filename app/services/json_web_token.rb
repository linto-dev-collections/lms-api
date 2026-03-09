class JsonWebToken
  class << self
    def encode(payload = {}, exp: nil)
      payload = payload.dup
      payload[:exp] ||= exp || AuthConfig.instance.access_token_expiry.seconds.from_now.to_i
      payload[:jti] ||= SecureRandom.uuid
      payload[:iat] = Time.current.to_i
      JWT.encode(payload, secret_key, algorithm)
    end

    def decode(token)
      decoded = JWT.decode(token, secret_key, true, { algorithm: algorithm })
      HashWithIndifferentAccess.new(decoded.first)
    rescue JWT::DecodeError
      nil
    end

    private

    def secret_key
      AuthConfig.instance.jwt_secret_key
    end

    def algorithm
      AuthConfig.instance.jwt_algorithm
    end
  end
end
