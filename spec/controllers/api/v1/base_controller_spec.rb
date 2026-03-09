# spec/controllers/api/v1/base_controller_spec.rb
require "rails_helper"

RSpec.describe Api::V1::BaseController, type: :controller do
  it "includes ErrorRenderable" do
    expect(described_class.ancestors).to include(ErrorRenderable)
  end

  it "includes Pagy::Method" do
    expect(described_class.ancestors).to include(Pagy::Method)
  end
end
