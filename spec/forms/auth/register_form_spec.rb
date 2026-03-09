require "rails_helper"

RSpec.describe Auth::RegisterForm do
  it "is valid with valid attributes" do
    form = described_class.new(
      email: "test@example.com",
      name: "テスト",
      password: "password123",
      password_confirmation: "password123"
    )
    expect(form).to be_valid
  end

  it "is invalid without email" do
    form = described_class.new(email: "", name: "テスト", password: "pass1234", password_confirmation: "pass1234")
    expect(form).not_to be_valid
    expect(form.errors[:email]).to be_present
  end

  it "is invalid when passwords don't match" do
    form = described_class.new(
      email: "test@example.com",
      name: "テスト",
      password: "password123",
      password_confirmation: "different"
    )
    expect(form).not_to be_valid
  end

  it "normalizes email" do
    form = described_class.new(
      email: "  TEST@Example.com  ",
      name: "テスト",
      password: "password123",
      password_confirmation: "password123"
    )
    form.validate
    expect(form.email).to eq("test@example.com")
  end

  it "is invalid with short password" do
    form = described_class.new(
      email: "test@example.com",
      name: "テスト",
      password: "short",
      password_confirmation: "short"
    )
    expect(form).not_to be_valid
    expect(form.errors[:password]).to be_present
  end
end
