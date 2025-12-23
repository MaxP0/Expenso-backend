class DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :authorize_manager!

  def index
    @expenses_by_category = ExpenseReport.group(:category).sum(:amount)
    @expenses_by_month = ExpenseReport.group_by_month(:date).sum(:amount)
    @total_expenses = ExpenseReport.sum(:amount)
    @submitted_count = ExpenseReport.submitted.count
  end

  private

  def authorize_manager!
    redirect_to root_path, alert: "Access denied" unless current_user.manager?
  end
end
