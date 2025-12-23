require "test_helper"

class ExpenseReportsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @employee = users(:one)
    @manager = users(:two)
    @draft_report = expense_reports(:one)
    @submitted_report = expense_reports(:three)
    @manager_owned_report = expense_reports(:two)
  end

  test "employee sees only own reports" do
    token = login_token_for(@employee)

    get api_v1_expense_reports_url, headers: auth_header(token)
    assert_response :success

    body = JSON.parse(response.body)
    assert_equal 2, body.fetch("expense_reports").size
  end

  test "manager sees all reports with owner" do
    token = login_token_for(@manager)

    get api_v1_expense_reports_url, headers: auth_header(token)
    assert_response :success

    body = JSON.parse(response.body)
    assert_equal 3, body.fetch("expense_reports").size
    assert body.fetch("expense_reports").all? { |r| r.key?("owner") }
  end

  test "employee can create report" do
    token = login_token_for(@employee)

    assert_difference("ExpenseReport.count", 1) do
      post api_v1_expense_reports_url,
        headers: auth_header(token),
        params: {
          expense_report: {
            title: "Taxi",
            category: "Travel",
            amount: 12.34,
            date: "2025-12-01",
            description: "Airport"
          }
        }
    end

    assert_response :created
  end

  test "employee can submit draft" do
    token = login_token_for(@employee)

    post submit_api_v1_expense_report_url(@draft_report), headers: auth_header(token)
    assert_response :success

    @draft_report.reload
    assert_equal "submitted", @draft_report.status
  end

  test "manager can approve submitted" do
    token = login_token_for(@manager)

    post approve_api_v1_expense_report_url(@submitted_report), headers: auth_header(token)
    assert_response :success

    @submitted_report.reload
    assert_equal "approved", @submitted_report.status
  end

  test "employee cannot access someone else's report" do
    token = login_token_for(@employee)

    get api_v1_expense_report_url(@manager_owned_report), headers: auth_header(token)
    assert_response :forbidden
  end

  private

  def login_token_for(user)
    post api_v1_auth_login_url, params: { email: user.email, password: "password123" }
    assert_response :success
    JSON.parse(response.body).fetch("token")
  end

  def auth_header(token)
    { "Authorization" => "Bearer #{token}" }
  end
end
