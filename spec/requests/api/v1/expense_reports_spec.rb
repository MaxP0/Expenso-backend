require 'rails_helper'

RSpec.describe 'API V1 Expense Reports', type: :request do
  def create_employee(email:)
    User.create!(email: email, password: 'password123', role: :employee)
  end

  def create_manager(email:)
    User.create!(email: email, password: 'password123', role: :manager)
  end

  it 'employee can create a report' do
    employee = create_employee(email: 'employee-create@example.com')

    post '/api/v1/expense_reports',
         params: {
           expense_report: {
             title: 'Taxi to client',
             category: 'Travel',
             amount: 19.5,
             date: '2025-12-23',
             description: 'Airport transfer'
           }
         },
         headers: auth_headers(employee),
         as: :json

    expect(response).to have_http_status(:created)

    body = JSON.parse(response.body)
    expect(body.fetch('expense_report').fetch('status')).to eq('draft')
    expect(body.fetch('expense_report').fetch('title')).to eq('Taxi to client')
  end

  it 'manager can approve a submitted report' do
    employee = create_employee(email: 'employee-approve-flow@example.com')
    manager = create_manager(email: 'manager-approve-flow@example.com')

    report = ExpenseReport.create!(
      user: employee,
      title: 'Meal',
      category: 'Meals',
      amount: 10,
      date: Date.new(2025, 12, 23),
      description: 'Lunch',
      status: :submitted
    )

    post "/api/v1/expense_reports/#{report.id}/approve", headers: auth_headers(manager), as: :json

    expect(response).to have_http_status(:ok)

    report.reload
    expect(report.status).to eq('approved')
  end

  it 'employee cannot approve a report' do
    employee = create_employee(email: 'employee-cannot-approve@example.com')

    report = ExpenseReport.create!(
      user: employee,
      title: 'Software',
      category: 'Software',
      amount: 50,
      date: Date.new(2025, 12, 23),
      description: 'License',
      status: :submitted
    )

    post "/api/v1/expense_reports/#{report.id}/approve", headers: auth_headers(employee), as: :json

    expect(response).to have_http_status(:forbidden)
    body = JSON.parse(response.body)
    expect(body.fetch('error')).to be_present

    report.reload
    expect(report.status).to eq('submitted')
  end
end
