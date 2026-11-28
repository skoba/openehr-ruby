require File.dirname(__FILE__) + '/../../../spec_helper'
require 'openehr/rm/data_types/quantity/date_time'

# #137 (resolution shape (b) enhancement; #80 gate B): BASE Foundation
# Types 1.2.0, 6.5.1, lists the offset as Z|±hh[:mm] (extended) and
# Z|±hh[mm] (compact). An hour-only offset (±hh) raised ArgumentError;
# it is now read as whole hours, also where the offset is turned into
# seconds for ordering (#108, #112).
describe 'Hour-only UTC offsets (#137)' do
  def time(value) = OpenEHR::AssumedLibraryTypes::ISO8601Time.new(value)
  def iso_dt(value) = OpenEHR::AssumedLibraryTypes::ISO8601DateTime.new(value)
  def dv_dt(value) = OpenEHR::RM::DataTypes::Quantity::DateTime::DvDateTime.new(value: value)

  %w[14:30:00+09 143000+09 14:30-05].each do |value|
    it "reads the time #{value}" do
      expect([time(value).hour, time(value).timezone]).to eq [14, value[/[+-]\d{2}\z/]]
    end

  end

  # Only positive offsets here: valid_iso8601_time? rejects every
  # negative offset, a separate bug (#141).
  %w[14:30:00+09 143000+09].each do |value|
    it "says the time #{value} is valid" do
      expect(OpenEHR::AssumedLibraryTypes::ISO8601Time.valid_iso8601_time?(value)).to be true
    end
  end

  %w[2026-03-01T10:00:00+09 20260301T100000+09 2026-03-01T10:00-05].each do |value|
    it "reads the date-time #{value}" do
      expect(iso_dt(value).timezone).to eq value[/[+-]\d{2}\z/]
    end
  end

  it 'gives +09 the magnitude of +09:00' do
    expect(dv_dt('2026-03-01T10:00:00+09').magnitude).to eq dv_dt('2026-03-01T10:00:00+09:00').magnitude
  end

  it 'gives -05 the magnitude of -05:00' do
    expect(dv_dt('2026-03-01T10:00:00-05').magnitude).to eq dv_dt('2026-03-01T10:00:00-05:00').magnitude
  end

  it 'reads -00 as offset 0' do
    expect(dv_dt('2026-03-01T10:00:00-00').magnitude).to eq dv_dt('2026-03-01T10:00:00Z').magnitude
  end

  it 'orders ISO8601DateTime with +09 by instant' do
    expect(iso_dt('2026-03-01T10:00:00+09') <=> iso_dt('2026-03-01T01:00:00Z')).to eq 0
  end

  # regression pin: already true before #137.
  it 'still reads ±hh:mm, ±hhmm and Z' do
    expect([dv_dt('2026-03-01T10:00:00+09:00'), dv_dt('2026-03-01T10:00:00+0900')].map(&:magnitude).uniq)
      .to eq [dv_dt('2026-03-01T01:00:00Z').magnitude]
  end
end
