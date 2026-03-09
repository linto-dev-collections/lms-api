module Authenticatable
  extend ActiveSupport::Concern

  private

  def authenticate_user!
    @current_user = authenticate_from_token
    render_error("認証が必要です", status: :unauthorized, code: "unauthorized") unless @current_user
  end

  def authenticate_user_if_present
    @current_user = authenticate_from_token
  end

  def current_user
    @current_user
  end

  def authenticate_from_token
    token = extract_token_from_header
    return nil unless token

    payload = JsonWebToken.decode(token)
    return nil unless payload

    User.find_by(id: payload[:sub])
  end

  def extract_token_from_header
    header = request.headers["Authorization"]
    return nil unless header&.start_with?("Bearer ")

    header.split(" ").last
  end
end
