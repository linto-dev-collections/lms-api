module Api
  module V1
    class AuthController < BaseController
      skip_before_action :authenticate_user!, only: [ :register, :login, :refresh ]

      # POST /api/v1/auth/register
      def register
        form = Auth::RegisterForm.new(register_params)
        unless form.valid?
          return render_validation_errors(form)
        end

        user = User.new(
          email: form.email,
          name: form.name,
          password: form.password,
          password_confirmation: form.password_confirmation,
          role: form.role.presence || "student"
        )

        unless user.save
          return render_validation_errors(user)
        end

        result = Auth::GenerateTokensService.call(user)
        case result
        in Dry::Monads::Success(tokens)
          render json: {
            user: serialize(user, with: UserSerializer),
            **tokens
          }, status: :created
        end
      end

      # POST /api/v1/auth/login
      def login
        form = Auth::LoginForm.new(login_params)
        unless form.valid?
          return render_validation_errors(form)
        end

        user = User.authenticate_by(email: form.email, password: form.password)
        unless user
          return render_error("メールアドレスまたはパスワードが正しくありません", status: :unauthorized, code: "invalid_credentials")
        end

        result = Auth::GenerateTokensService.call(user)
        case result
        in Dry::Monads::Success(tokens)
          render json: {
            user: serialize(user, with: UserSerializer),
            **tokens
          }, status: :ok
        end
      end

      # DELETE /api/v1/auth/logout
      def logout
        refresh_token_raw = params[:refresh_token]
        if refresh_token_raw.present?
          Auth::RevokeRefreshTokenService.call(refresh_token_raw)
        end
        head :no_content
      end

      # POST /api/v1/auth/refresh
      def refresh
        refresh_token_raw = params.expect(:refresh_token)

        case Auth::RefreshTokensService.call(refresh_token_raw)
        in Dry::Monads::Success(tokens)
          render json: tokens, status: :ok
        in Dry::Monads::Failure(:token_not_found) | Dry::Monads::Failure(:token_expired)
          render_error("リフレッシュトークンが無効です", status: :unauthorized, code: "invalid_refresh_token")
        in Dry::Monads::Failure(:token_reused)
          render_error("リフレッシュトークンの再利用が検知されました。セキュリティのため全セッションが無効化されました",
                       status: :unauthorized, code: "token_reuse_detected")
        end
      end

      private

      def register_params
        params.expect(user: [ :email, :name, :password, :password_confirmation, :role ])
      rescue ActionController::ParameterMissing
        params.permit(:email, :name, :password, :password_confirmation)
      end

      def login_params
        params.expect(auth: [ :email, :password ])
      rescue ActionController::ParameterMissing
        params.permit(:email, :password)
      end
    end
  end
end
