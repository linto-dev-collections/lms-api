module AuthHelper
  def auth_headers_for(user)
    token = JsonWebToken.encode({ sub: user.id, role: user.role })
    { "Authorization" => "Bearer #{token}" }
  end
end

RSpec.configure do |config|
  config.include AuthHelper, type: :request
end
