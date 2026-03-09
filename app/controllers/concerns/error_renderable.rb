# app/controllers/concerns/error_renderable.rb
module ErrorRenderable
  extend ActiveSupport::Concern

  included do
    rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
    rescue_from ActionPolicy::Unauthorized, with: :render_forbidden
    rescue_from ActionController::ParameterMissing, with: :render_bad_request
    rescue_from AASM::InvalidTransition, with: :render_conflict

    # 本番環境でのみ全エラーをキャッチ（フォールバック）
    rescue_from StandardError, with: :render_internal_server_error unless Rails.env.local?
  end

  private

  def render_error(message, status:, code: nil, details: nil)
    body = {
      error: {
        code: code || error_code_from_status(status),
        message: message
      }
    }
    body[:error][:details] = details if details
    render json: body, status: status
  end

  def render_validation_errors(form_or_record)
    details = form_or_record.errors.map do |error|
      { field: error.attribute.to_s, message: error.message }
    end
    render_error(
      "入力内容に誤りがあります",
      status: :unprocessable_entity,
      code: "validation_failed",
      details: details
    )
  end

  def render_not_found(exception)
    render_error(
      exception.message,
      status: :not_found,
      code: "not_found"
    )
  end

  def render_forbidden(_exception)
    render_error(
      "この操作を実行する権限がありません",
      status: :forbidden,
      code: "forbidden"
    )
  end

  def render_bad_request(exception)
    render_error(
      exception.message,
      status: :bad_request,
      code: "bad_request"
    )
  end

  def render_conflict(exception)
    render_error(
      exception.message,
      status: :conflict,
      code: "invalid_transition"
    )
  end

  def render_internal_server_error(exception)
    Rails.error.report(exception, handled: true, context: {
      controller: controller_name,
      action: action_name,
      user_id: current_user&.id
    })

    render_error(
      "サーバーエラーが発生しました",
      status: :internal_server_error,
      code: "internal_server_error"
    )
  end

  def error_code_from_status(status)
    Rack::Utils::SYMBOL_TO_STATUS_CODE
      .key(Rack::Utils.status_code(status))
      .to_s
  end
end
