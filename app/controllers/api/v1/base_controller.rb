# app/controllers/api/v1/base_controller.rb
module Api
  module V1
    class BaseController < ActionController::API
      include ErrorRenderable
      include Authenticatable
      include ActionPolicy::Controller
      include Pagy::Method

      authorize :user, through: :current_user

      before_action :authenticate_user!

      after_action :set_pagy_headers

      private

      def set_pagy_headers
        response.headers.merge!(@pagy.headers_hash) if @pagy
      end

      def pagy_metadata(pagy_obj)
        {
          current_page: pagy_obj.page,
          total_pages: pagy_obj.pages,
          total_count: pagy_obj.count,
          per_page: pagy_obj.limit
        }
      end

      def serialize(resource, with: nil, **options)
        serializer = with || default_serializer_for(resource)
        serializer.new(resource, **options).serializable_hash
      end

      def default_serializer_for(resource)
        klass = resource.is_a?(ActiveRecord::Relation) ? resource.klass : resource.class
        "#{klass.name}Serializer".constantize
      end
    end
  end
end
