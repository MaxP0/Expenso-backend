require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  setup do
    @manager = users(:two)
  end

  test "manager can fetch dashboard" do
    token = login_token_for(@manager)

    get api_v1_dashboard_url, headers: { "Authorization" => "Bearer #{token}" }
    assert_response :success

    body = JSON.parse(response.body)
    assert body.key?("total_expenses")
    assert body.key?("submitted_count")
    assert body.key?("expenses_by_category")
    assert body.key?("expenses_by_month")
  end

  private

  def login_token_for(user)
    post api_v1_auth_login_url, params: { email: user.email, password: "password123" }
    assert_response :success
    JSON.parse(response.body).fetch("token")
  end
end
