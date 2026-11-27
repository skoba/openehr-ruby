require File.dirname(__FILE__) + '/../../../spec_helper'
require 'openehr/rm/data_types/quantity/date_time'

# #138 (resolution shape (a) bug; #80 gate C): BASE Foundation Types
# 1.2.0, 6.5.5-6.5.6, as_string returns the extended format, offset
# included. The offset was written as given (+0900); it is now written
# as ±hh:mm. A DV_ value keeps the string it was given.
describe 'as_string writes the offset in the extended form (#138)' do
  def build(kind, value)
    case kind
    when :time then OpenEHR::AssumedLibraryTypes::ISO8601Time.new(value)
    when :date_time then OpenEHR::AssumedLibraryTypes::ISO8601DateTime.new(value)
    when :dv_time then OpenEHR::RM::DataTypes::Quantity::DateTime::DvTime.new(value: value)
    when :dv_date_time then OpenEHR::RM::DataTypes::Quantity::DateTime::DvDateTime.new(value: value)
    end
  end

  [
    [:time, '14:30:00+0900', '14:30:00+09:00'],
    [:time, '143000-0530', '14:30:00-05:30'],
    [:date_time, '2026-09-22T14:30:00+0900', '2026-09-22T14:30:00+09:00'],
    [:date_time, '20260922T143000+0900', '2026-09-22T14:30:00+09:00'],
    [:dv_date_time, '20260922T143000+0900', '2026-09-22T14:30:00+09:00'],
    [:dv_time, '14:30:00+0900', '14:30:00+09:00']
  ].each do |kind, value, expected|
    it "writes #{kind} #{value} as #{expected}" do
      expect(build(kind, value).as_string).to eq expected
    end
  end

  # regression pin: already true before #138.
  it 'keeps +09:00 and Z' do
    expect([build(:time, '14:30:00+09:00').as_string, build(:date_time, '2026-09-22T14:30:00Z').as_string])
      .to eq ['14:30:00+09:00', '2026-09-22T14:30:00Z']
  end

  # regression pin: already true before #138.
  it 'keeps the DV_ value as given' do
    expect(build(:dv_date_time, '20260922T143000+0900').value).to eq '20260922T143000+0900'
  end
end
