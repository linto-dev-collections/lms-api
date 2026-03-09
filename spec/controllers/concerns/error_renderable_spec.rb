# spec/controllers/concerns/error_renderable_spec.rb
require "rails_helper"

RSpec.describe ErrorRenderable, type: :controller do
  controller(ActionController::API) do
    include ErrorRenderable

    def not_found_action
      raise ActiveRecord::RecordNotFound, "Couldn't find Record"
    end

    def parameter_missing_action
      raise ActionController::ParameterMissing, :name
    end

    def custom_error_action
      render_error("something went wrong", status: :internal_server_error)
    end

    def validation_error_action
      obj = Object.new
      errors = ActiveModel::Errors.new(obj)
      errors.add(:email, "is invalid")
      obj.define_singleton_method(:errors) { errors }
      render_validation_errors(obj)
    end
  end

  before do
    routes.draw do
      get "not_found_action" => "anonymous#not_found_action"
      get "parameter_missing_action" => "anonymous#parameter_missing_action"
      get "custom_error_action" => "anonymous#custom_error_action"
      get "validation_error_action" => "anonymous#validation_error_action"
    end
  end

  describe "rescue_from ActiveRecord::RecordNotFound" do
    it "returns 404 with error JSON" do
      get :not_found_action
      expect(response).to have_http_status(:not_found)
      body = JSON.parse(response.body)
      expect(body["error"]["code"]).to eq("not_found")
    end
  end

  describe "rescue_from ActionController::ParameterMissing" do
    it "returns 400 with error JSON" do
      get :parameter_missing_action
      expect(response).to have_http_status(:bad_request)
      body = JSON.parse(response.body)
      expect(body["error"]["code"]).to eq("bad_request")
    end
  end

  describe "#render_error" do
    it "returns error JSON with status" do
      get :custom_error_action
      expect(response).to have_http_status(:internal_server_error)
      body = JSON.parse(response.body)
      expect(body["error"]["message"]).to eq("something went wrong")
    end
  end

  describe "#render_validation_errors" do
    it "returns 422 with validation details" do
      get :validation_error_action
      expect(response).to have_http_status(:unprocessable_entity)
      body = JSON.parse(response.body)
      expect(body["error"]["code"]).to eq("validation_failed")
      expect(body["error"]["details"].first["field"]).to eq("email")
    end
  end
end
