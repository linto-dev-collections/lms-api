require "rails_helper"

RSpec.describe JsonWebToken do
  describe ".encode / .decode" do
    it "encodes and decodes a payload" do
      payload = { sub: 1, role: "student" }
      token = described_class.encode(payload)
      decoded = described_class.decode(token)

      expect(decoded[:sub]).to eq(1)
      expect(decoded[:role]).to eq("student")
      expect(decoded[:jti]).to be_present
    end

    it "returns nil for invalid token" do
      expect(described_class.decode("invalid")).to be_nil
    end

    it "returns nil for expired token" do
      token = described_class.encode({ sub: 1 }, exp: 1.hour.ago.to_i)
      expect(described_class.decode(token)).to be_nil
    end
  end
end
