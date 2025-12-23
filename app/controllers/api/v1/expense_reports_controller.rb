# frozen_string_literal: true

module Api
  module V1
    class ExpenseReportsController < Api::BaseController
      include Rails.application.routes.url_helpers

      before_action :set_expense_report, only: %i[show update destroy submit approve reject]

      def index
        scope = current_user.manager? ? ExpenseReport.all : current_user.expense_reports
        reports = scope.includes(:user).order(created_at: :desc)

        render json: {
          expense_reports: reports.map { |report| expense_report_payload(report) }
        }
      end

      def show
        return if authorize_report_access!(@expense_report) == false

        render json: { expense_report: expense_report_payload(@expense_report) }
      end

      def create
        return render_forbidden("Only employees can create reports") unless current_user.employee?

        report = current_user.expense_reports.build(expense_report_params)
        report.status = :draft

        if report.save
          render json: { expense_report: expense_report_payload(report) }, status: :created
        else
          render json: { errors: report.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        return if authorize_report_access!(@expense_report) == false

        unless @expense_report.user_id == current_user.id && @expense_report.draft?
          return render_forbidden("Cannot edit this report")
        end

        if @expense_report.update(expense_report_params)
          render json: { expense_report: expense_report_payload(@expense_report) }
        else
          render json: { errors: @expense_report.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        return if authorize_report_access!(@expense_report) == false

        unless @expense_report.user_id == current_user.id && @expense_report.draft?
          return render_forbidden("Cannot delete this report")
        end

        @expense_report.destroy
        render json: { ok: true }
      end

      def submit
        return if authorize_report_access!(@expense_report) == false

        unless current_user.employee? && @expense_report.user_id == current_user.id && @expense_report.draft?
          return render_forbidden("Cannot submit this report")
        end

        @expense_report.update!(status: :submitted)
        render json: { expense_report: expense_report_payload(@expense_report) }
      end

      def approve
        require_manager!
        return if performed?

        return render_forbidden("Only submitted reports can be approved") unless @expense_report.submitted?

        @expense_report.update!(status: :approved)
        render json: { expense_report: expense_report_payload(@expense_report) }
      end

      def reject
        require_manager!
        return if performed?

        return render_forbidden("Only submitted reports can be rejected") unless @expense_report.submitted?

        @expense_report.update!(status: :rejected)
        render json: { expense_report: expense_report_payload(@expense_report) }
      end

      private

      def set_expense_report
        @expense_report = ExpenseReport.includes(:user).find(params[:id])
      end

      def authorize_report_access!(report)
        return true if current_user.manager?
        return true if report.user_id == current_user.id

        render_forbidden("Access denied")
        false
      end

      def expense_report_params
        params.require(:expense_report).permit(:title, :category, :amount, :date, :description, :receipt)
      end

      def expense_report_payload(report)
        payload = {
          id: report.id,
          title: report.title,
          category: report.category,
          amount: report.amount&.to_f,
          date: report.date,
          description: report.description,
          status: report.status,
          created_at: report.created_at,
          updated_at: report.updated_at,
          receipt_url: receipt_url_for(report)
        }

        if current_user.manager?
          payload[:owner] = {
            id: report.user_id,
            email: report.user.email
          }
        end

        payload
      end

      def receipt_url_for(report)
        return nil unless report.receipt.attached?

        rails_blob_url(report.receipt, host: request.base_url)
      end
    end
  end
end
