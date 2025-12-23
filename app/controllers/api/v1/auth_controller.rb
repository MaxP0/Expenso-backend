# frozen_string_literal: true

module Api
  module V1
    class AuthController < ActionController::API
      include ActionController::MimeResponds

      # POST /api/v1/auth/login
      # { "email": "...", "password": "..." }
      def login
        email = params[:email].to_s.downcase.strip
        password = params[:password].to_s

        user = User.find_by(email: email)
        return render json: { error: "Invalid email or password" }, status: :unauthorized if user.nil?
        return render json: { error: "Invalid email or password" }, status: :unauthorized unless user.valid_password?(password)

        user.regenerate_api_token

        render json: {
          token: user.api_token,
          user: user_payload(user)
        }
      end

      # DELETE /api/v1/auth/logout
      def logout
        token = bearer_token
        user = token.present? ? User.find_by(api_token: token) : nil
        user&.regenerate_api_token

        render json: { ok: true }
      end

      # GET /api/v1/auth/me
      def me
        token = bearer_token
        user = token.present? ? User.find_by(api_token: token) : nil
        return render json: { error: "Unauthorized" }, status: :unauthorized if user.nil?

        render json: { user: user_payload(user) }
      end

      private

      def bearer_token
        header = request.headers["Authorization"].to_s
        return nil unless header.start_with?("Bearer ")

        header.delete_prefix("Bearer ").strip
      end

      def user_payload(user)
        {
          id: user.id,
          email: user.email,
          role: user.role
        }
      end
    end
  end
end
