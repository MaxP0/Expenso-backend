# frozen_string_literal: true

module Api
  module V1
    class DashboardController < Api::BaseController
      def show
        require_manager!
        return if performed?

        total_expenses = ExpenseReport.sum(:amount).to_f
        submitted_count = ExpenseReport.submitted.count

        by_category = ExpenseReport.group(:category).sum(:amount).map do |category, amount|
          { category: category, amount: amount.to_f }
        end

        by_month = ExpenseReport.group_by_month(:date, format: "%Y-%m").sum(:amount).map do |month, amount|
          { month: month, amount: amount.to_f }
        end

        render json: {
          total_expenses: total_expenses,
          submitted_count: submitted_count,
          expenses_by_category: by_category,
          expenses_by_month: by_month
        }
      end
    end
  end
end
