# spec/routing/api_v1_routing_spec.rb
require "rails_helper"

RSpec.describe "API v1 routing", type: :routing do
  it "has the health check route" do
    expect(get: "/up").to route_to("rails/health#show")
  end
end
