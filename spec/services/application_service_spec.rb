# spec/services/application_service_spec.rb
require "rails_helper"

RSpec.describe ApplicationService do
  it "extends Dry::Initializer" do
    expect(described_class).to respond_to(:option)
    expect(described_class).to respond_to(:param)
  end

  it "includes Dry::Monads[:result, :do]" do
    service = described_class.new
    expect(service).to respond_to(:Success)
    expect(service).to respond_to(:Failure)
  end

  describe ".call" do
    let(:test_service_class) do
      Class.new(described_class) do
        def call
          Success("ok")
        end
      end
    end

    it "instantiates and calls" do
      result = test_service_class.call
      expect(result).to be_success
      expect(result.value!).to eq("ok")
    end
  end
end
