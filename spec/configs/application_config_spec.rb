# spec/configs/application_config_spec.rb
require "rails_helper"

RSpec.describe ApplicationConfig do
  describe ".instance" do
    it "returns a singleton instance" do
      expect(described_class.instance).to be_a(described_class)
      expect(described_class.instance).to equal(described_class.instance)
    end
  end
end
