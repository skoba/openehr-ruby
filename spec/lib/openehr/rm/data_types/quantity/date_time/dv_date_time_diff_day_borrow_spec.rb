require File.dirname(__FILE__) + '/../../../../../../spec_helper'
require 'openehr/rm/data_types/quantity/date_time'

# #118 (resolution shape (a) bug): when the later value's time of day is
# before the earlier one's, diff borrows a day from the later date. It
# did so by setting day - 1, which raised "Day is not valid" when the
# later date was the 1st of a month.
describe OpenEHR::RM::DataTypes::Quantity::DateTime::DvDateTime, '#diff borrowing a day (#118)' do
  def dt(value) = described_class.new(value: value)

  it 'borrows across a month end' do
    expect(dt('2026-01-31T12:00:00Z').diff(dt('2026-02-01T00:00:00Z')).value).to eq 'P0Y0M0W0DT12H0M0S'
  end

  it 'borrows across a year end' do
    expect(dt('2026-12-31T16:00:00Z').diff(dt('2027-01-01T00:00:00Z')).value).to eq 'P0Y0M0W0DT8H0M0S'
  end

  it 'borrows across a leap day' do
    expect(dt('2024-02-29T23:00:00Z').diff(dt('2024-03-01T01:00:00Z')).value).to eq 'P0Y0M0W0DT2H0M0S'
  end

  # regression pin: a borrow inside a month already worked before #118.
  it 'borrows inside a month' do
    expect(dt('2026-03-01T12:00:00Z').diff(dt('2026-03-02T00:00:00Z')).value).to eq 'P0Y0M0W0DT12H0M0S'
  end
end
