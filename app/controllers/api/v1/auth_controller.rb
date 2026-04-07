module Api
  module V1
    class AuthController < BaseController
      skip_before_action :authenticate_user!, only: [ :register, :login, :refresh, :verify_email, :resend_verification ]

      rate_limit to: 5, within: 15.minutes, only: [ :login, :register ], name: "auth-credential"
      rate_limit to: 3, within: 1.hour, only: [ :resend_verification ], name: "auth-resend"
      rate_limit to: 10, within: 15.minutes, only: [ :verify_email ], name: "auth-verify"
      rate_limit to: 20, within: 1.hour, only: [ :refresh ], name: "auth-refresh"

      before_action :set_no_cache_headers, only: [ :login, :verify_email, :refresh ]

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

        Auth::SendVerificationEmailService.call(user)

        render json: {
          message: "確認メールを送信しました。メールに記載されたトークンを使用してアカウントを認証してください。"
        }, status: :created
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

        unless user.email_verified?
          return render_error(
            "メールアドレスの確認が完了していません。確認メールに記載されたトークンを使用してアカウントを認証してください。",
            status: :forbidden,
            code: "email_not_verified"
          )
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

      # POST /api/v1/auth/verify_email
      def verify_email
        form = Auth::VerifyEmailForm.new(verify_email_params)
        unless form.valid?
          return render_validation_errors(form)
        end

        case Auth::VerifyEmailService.call(form.token)
        in Dry::Monads::Success(result)
          render json: {
            user: serialize(result[:user], with: UserSerializer),
            access_token: result[:access_token],
            refresh_token: result[:refresh_token],
            token_type: result[:token_type],
            expires_in: result[:expires_in]
          }, status: :ok
        in Dry::Monads::Failure(:invalid_token)
          render_error(
            "認証トークンが無効または有効期限切れです",
            status: :unprocessable_entity,
            code: "invalid_verification_token"
          )
        in Dry::Monads::Failure(:already_verified)
          render_error(
            "このアカウントは既に認証済みです",
            status: :unprocessable_entity,
            code: "already_verified"
          )
        end
      end

      # POST /api/v1/auth/resend_verification
      def resend_verification
        form = Auth::ResendVerificationForm.new(resend_verification_params)
        unless form.valid?
          return render_validation_errors(form)
        end

        user = User.find_by(email: form.email)

        # ユーザーが存在しない場合も同一レスポンスを返す（メールアドレス列挙攻撃対策）
        if user
          Auth::SendVerificationEmailService.call(user)
        end

        render json: {
          message: "メールアドレスが登録されている場合、確認メールを送信しました。"
        }, status: :ok
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

      def verify_email_params
        params.permit(:token)
      end

      def resend_verification_params
        params.permit(:email)
      end

      def set_no_cache_headers
        response.headers["Cache-Control"] = "no-store"
        response.headers["Pragma"] = "no-cache"
      end
    end
  end
end
