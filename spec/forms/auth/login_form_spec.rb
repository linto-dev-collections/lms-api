require "rails_helper"

RSpec.describe Auth::LoginForm do
  it "is valid with email and password" do
    form = described_class.new(email: "test@example.com", password: "password123")
    expect(form).to be_valid
  end

  it "normalizes email" do
    form = described_class.new(email: "  TEST@Example.com  ", password: "pass")
    form.validate
    expect(form.email).to eq("test@example.com")
  end

  it "is invalid without email" do
    form = described_class.new(email: "", password: "pass")
    expect(form).not_to be_valid
  end

  it "is invalid without password" do
    form = described_class.new(email: "test@example.com", password: "")
    expect(form).not_to be_valid
  end
end
