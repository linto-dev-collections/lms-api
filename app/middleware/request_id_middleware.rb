# app/middleware/request_id_middleware.rb
class RequestIdMiddleware
  def initialize(app)
    @app = app
  end

  def call(env)
    request_id = env["action_dispatch.request_id"]
    Rails.logger.tagged(request_id) do
      @app.call(env)
    end
  end
end
