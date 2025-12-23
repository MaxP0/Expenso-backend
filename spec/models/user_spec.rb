require 'rails_helper'

RSpec.describe User, type: :model do
  it 'defines role enum values' do
    expect(described_class.roles.keys).to match_array(%w[employee manager])
  end
end
