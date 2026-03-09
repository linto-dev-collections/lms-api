module Api
  module V1
    class UsersController < BaseController
      before_action :set_user, only: [ :show ]

      # GET /api/v1/users/me
      def me
        render json: serialize(current_user, with: UserSerializer)
      end

      # PATCH /api/v1/users/me
      def update_me
        if current_user.update(me_params)
          render json: serialize(current_user, with: UserSerializer)
        else
          render_validation_errors(current_user)
        end
      end

      # GET /api/v1/users
      def index
        authorize! User, with: UserPolicy
        users = User.all
        pagy, records = pagy(:offset, users)
        render json: {
          users: records.map { |u| serialize(u, with: UserSerializer) },
          meta: pagy_metadata(pagy)
        }
      end

      # GET /api/v1/users/:id
      def show
        authorize! @user, with: UserPolicy
        render json: serialize(@user, with: UserSerializer)
      end

      private

      def set_user
        @user = User.find(params[:id])
      end

      def me_params
        params.permit(:name)
      end
    end
  end
end
