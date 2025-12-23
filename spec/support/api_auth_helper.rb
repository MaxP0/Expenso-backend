module ApiAuthHelper
  def auth_headers(user)
    user.regenerate_api_token if user.api_token.blank?
    {
      'Authorization' => "Bearer #{user.api_token}",
      'Content-Type' => 'application/json'
    }
  end
end
