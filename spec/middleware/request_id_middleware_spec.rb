# spec/middleware/request_id_middleware_spec.rb
require "rails_helper"

RSpec.describe RequestIdMiddleware do
  let(:app) { ->(env) { [ 200, env, "OK" ] } }
  let(:middleware) { described_class.new(app) }

  it "passes the request through" do
    env = { "action_dispatch.request_id" => "test-request-id-123" }
    status, _headers, _body = middleware.call(env)
    expect(status).to eq(200)
  end
end
