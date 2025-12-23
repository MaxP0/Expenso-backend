require 'rails_helper'

RSpec.describe ExpenseReport, type: :model do
  let(:user) do
    User.create!(
      email: 'employee-model@example.com',
      password: 'password123',
      role: :employee
    )
  end

  it 'validates presence of title, category, amount, date' do
    report = described_class.new(user: user)

    expect(report).not_to be_valid
    expect(report.errors[:title]).to be_present
    expect(report.errors[:category]).to be_present
    expect(report.errors[:amount]).to be_present
    expect(report.errors[:date]).to be_present
  end

  it 'defines status enum values' do
    expect(described_class.statuses.keys).to match_array(%w[draft submitted approved rejected])
  end
end
