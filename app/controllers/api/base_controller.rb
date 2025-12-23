# frozen_string_literal: true

module Api
  class BaseController < ActionController::API
    include ActionController::MimeResponds

    before_action :authenticate_api_user!

    attr_reader :current_user

    private

    def authenticate_api_user!
      token = bearer_token
      return render_unauthorized("Missing token") if token.blank?

      user = User.find_by(api_token: token)
      return render_unauthorized("Invalid token") if user.nil?

      @current_user = user
    end

    def bearer_token
      header = request.headers["Authorization"].to_s
      return nil unless header.start_with?("Bearer ")

      header.delete_prefix("Bearer ").strip
    end

    def render_unauthorized(message)
      render json: { error: message }, status: :unauthorized
    end

    def render_forbidden(message)
      render json: { error: message }, status: :forbidden
    end

    def require_manager!
      return if current_user&.manager?

      render_forbidden("Access denied")
    end
  end
end
