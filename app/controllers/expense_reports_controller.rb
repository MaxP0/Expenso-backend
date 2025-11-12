class ExpenseReportsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_expense_report, only: %i[ show edit update destroy submit approve reject ]

  def index
    if current_user.manager?
      @expense_reports = ExpenseReport.order(created_at: :desc)
    else
      @expense_reports = current_user.expense_reports.order(created_at: :desc)
    end
  end

  def show
  end

  def new
    @expense_report = ExpenseReport.new
  end

  def edit
    unless @expense_report.draft? && @expense_report.user == current_user
      redirect_to @expense_report, alert: "You can't edit this report"
    end
  end

  def create
    @expense_report = current_user.expense_reports.build(expense_report_params)
    @expense_report.status = :draft

    if @expense_report.save
      redirect_to @expense_report, notice: "Expense report created successfully."
    else
      render :new
    end
  end

  def update
    if @expense_report.draft? && @expense_report.user == current_user && @expense_report.update(expense_report_params)
      redirect_to @expense_report, notice: "Report updated."
    else
      redirect_to @expense_report, alert: "Cannot edit a submitted report."
    end
  end

  def destroy
    if @expense_report.user == current_user && @expense_report.draft?
      @expense_report.destroy
      redirect_to expense_reports_url, notice: "Expense report deleted."
    else
      redirect_to expense_reports_url, alert: "Action not allowed."
    end
  end

  # Custom actions
  def submit
    if current_user.employee? && @expense_report.draft? && @expense_report.user == current_user
      @expense_report.update(status: :submitted)
      redirect_to expense_reports_path, notice: "Report submitted successfully."
    else
      redirect_to expense_reports_path, alert: "Action not allowed."
    end
  end

  def approve
    if current_user.manager?
      @expense_report.update(status: :approved)
      flash[:notice] = "Report approved and sent to accounting department."
      redirect_to expense_reports_path
    else
      redirect_to root_path, alert: "Access denied."
    end
  end

  def reject
    if current_user.manager?
      @expense_report.update(status: :rejected)
      redirect_to expense_reports_path, notice: "Report rejected."
    else
      redirect_to root_path, alert: "Access denied."
    end
  end

  private

  def set_expense_report
    @expense_report = ExpenseReport.find(params[:id])
  end

  def expense_report_params
  params.require(:expense_report).permit(:title, :category, :amount, :date, :description, :receipt)
  end
end
