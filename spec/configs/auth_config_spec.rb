# spec/configs/auth_config_spec.rb
require "rails_helper"

RSpec.describe AuthConfig do
  subject(:config) { described_class.new }

  it "has access_token_expiry" do
    expect(config.access_token_expiry).to eq(300)
  end

  it "has refresh_token_expiry" do
    expect(config.refresh_token_expiry).to eq(3600)
  end

  it "has jwt_algorithm" do
    expect(config.jwt_algorithm).to eq("HS256")
  end

  it "has refresh_token_reuse_detection" do
    expect(config.refresh_token_reuse_detection).to be(true)
  end
end
