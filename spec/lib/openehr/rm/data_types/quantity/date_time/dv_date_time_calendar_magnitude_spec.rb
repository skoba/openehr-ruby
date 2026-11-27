require File.dirname(__FILE__) + '/../../../../../../spec_helper'
require File.dirname(__FILE__) + '/../../../../aql/fixtures/blood_pressure_builder'
require 'openehr/rm/data_types/quantity/date_time'

# #117 (resolution shape (a) bug): the RM defines DV_DATE_TIME.magnitude
# as the seconds since 0001-01-01T00:00:00Z (RM Data Types 7.2), and
# comparison goes through magnitude. Before #117, magnitude counted a
# year as 365.24 days and a month as 30.42 days, so a 31-day month
# overlapped the next one and order inverted near its end.
describe OpenEHR::RM::DataTypes::Quantity::DateTime::DvDateTime, '#magnitude in calendar seconds (#117)' do
  def dt(value) = described_class.new(value: value)

  def calendar_seconds(year, month, day)
    (Date.new(year, month, day, Date::GREGORIAN).jd - Date.new(1, 1, 1, Date::GREGORIAN).jd) * 86_400
  end

  it 'is 0 at 0001-01-01T00:00:00Z' do
    expect(dt('0001-01-01T00:00:00Z').magnitude).to eq 0
  end

  it 'counts calendar days since 0001-01-01' do
    expect(dt('2026-11-27T00:00:00Z').magnitude).to eq calendar_seconds(2026, 11, 27)
  end

  [
    %w[2026-01-31T12:00:00Z 2026-02-01T00:00:00Z],
    %w[2026-03-31T10:30:00Z 2026-04-01T00:00:00Z],
    %w[2026-12-31T16:00:00Z 2027-01-01T00:00:00Z]
  ].each do |earlier, later|
    it "orders #{earlier} before #{later}" do
      expect(dt(earlier)).to be < dt(later)
    end
  end

  # regression pin: already true before #117 (February is shorter than
  # the nominal month, so it did not invert).
  it 'orders 2024-02-29T23:00:00Z before 2024-03-01T00:00:00Z' do
    expect(dt('2024-02-29T23:00:00Z')).to be < dt('2024-03-01T00:00:00Z')
  end

  # regression pin: already true before #117 (#108).
  it 'still subtracts the UTC offset' do
    expect(dt('2026-03-01T10:00:00+09:00') <=> dt('2026-03-01T01:00:00Z')).to eq 0
  end

  # regression pin: already true before #117 (#59). A missing month or
  # day counts as 1 for ordering only; the value keeps its precision.
  it 'orders a year-only value as its earliest instant' do
    expect(dt('2026') <=> dt('2026-01-01T00:00:00Z')).to eq 0
    expect(dt('2026').value).to eq '2026'
  end

  # regression pin: already true before #117.
  it 'orders a month-only value as its earliest instant' do
    expect(dt('2026-11') <=> dt('2026-11-01T00:00:00Z')).to eq 0
  end

  describe 'through AQL' do
    let(:builder) { OpenEHR::AQL::Fixtures::BloodPressureBuilder }
    let(:from) { 'FROM EHR e CONTAINS COMPOSITION c CONTAINS OBSERVATION o' }
    let(:time) { 'o/data[at0001]/events[at0006]/time' }
    let(:systolic) { 'o/data[at0001]/events[at0006]/data[at0003]/items[at0004]/value/magnitude' }
    let(:dataset) do
      OpenEHR::AQL::Dataset.of_compositions(
        [builder.blood_pressure_composition(systolic: 120, diastolic: 80, start_time: '2026-01-31T12:00:00Z'),
         builder.blood_pressure_composition(systolic: 130, diastolic: 80, start_time: '2026-02-01T00:00:00Z')]
      )
    end

    it 'ORDER BY .../time sorts by the instant' do
      result = OpenEHR::AQL.execute("SELECT #{systolic} #{from} ORDER BY #{time} ASC", dataset)
      expect(result.rows).to eq [[120], [130]]
    end

    it 'ORDER BY .../time/magnitude sorts by the instant' do
      result = OpenEHR::AQL.execute("SELECT #{systolic} #{from} ORDER BY #{time}/magnitude ASC", dataset)
      expect(result.rows).to eq [[120], [130]]
    end

    it 'WHERE on .../time/magnitude compares the instant' do
      result = OpenEHR::AQL.execute(
        "SELECT #{systolic} #{from} WHERE #{time}/magnitude < $limit", dataset,
        params: { limit: calendar_seconds(2026, 2, 1) }
      )
      expect(result.rows).to eq [[120]]
    end
  end
end
