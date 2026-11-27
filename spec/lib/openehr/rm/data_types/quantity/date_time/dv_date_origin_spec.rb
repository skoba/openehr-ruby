require File.dirname(__FILE__) + '/../../../../../../spec_helper'
require 'openehr/rm/data_types/quantity/date_time'

# #126 (resolution shape (a) bug): RM Data Types 7.2.2 defines
# DV_DATE.magnitude as "days since the calendar origin date 0001-01-01".
# Before #126 it counted from 0000-01-01 on Ruby's default calendar, so
# 2026-11-27 gave 740314 instead of 739946.
describe OpenEHR::RM::DataTypes::Quantity::DateTime::DvDate, '#magnitude origin (#126)' do
  def date(value) = described_class.new(value: value)

  it 'is 0 at 0001-01-01' do
    expect(date('0001-01-01').magnitude).to eq 0
  end

  it 'counts calendar days since 0001-01-01' do
    expect(date('2026-11-27').magnitude).to eq 739_946
  end

  it 'is a whole number of days' do
    expect(date('2026-11-27').magnitude).to be_an Integer
  end

  # regression pin: full dates already ordered correctly before #126.
  it 'still orders full dates by the calendar' do
    expect(date('2026-01-31')).to be < date('2026-02-01')
    expect(date('2024-02-29')).to be < date('2024-03-01')
  end
end
