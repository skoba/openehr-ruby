require File.dirname(__FILE__) + '/../../../../spec_helper'
require File.dirname(__FILE__) + '/../fixtures/blood_pressure_builder'

# #134 (resolution shape (a) bug): AQL (QUERY 3.12.5) compares a
# date-time path itself with a quoted ISO 8601 literal. Before #134 that
# raised NoMethodError (DvQuantified#<=> called magnitude on the String).
# The literal is now read as the path's type and compared by instant,
# with the ordering count of #117/#120 (a partial value is its earliest
# instant, no offset means UTC). Plan:
# docs/design/134-aql-date-time-literal-plan.md.
describe 'AQL: a date-time path compared with an ISO 8601 literal (#134)' do
  let(:builder) { OpenEHR::AQL::Fixtures::BloodPressureBuilder }
  let(:from) { 'FROM EHR e CONTAINS COMPOSITION c' }
  let(:start) { 'c/context/start_time' }
  let(:data) { dataset('2026-02-28T23:30:00Z', '2026-03-01T08:00:00+09:00', '2026-03-15') }

  def dataset(*start_times)
    OpenEHR::AQL::Dataset.of_compositions(
      start_times.map { |t| builder.blood_pressure_composition(systolic: 120, diastolic: 80, start_time: t) }
    )
  end

  def starts(where, data, params = {})
    OpenEHR::AQL.execute("SELECT #{start}/value #{from} WHERE #{where}", data, params: params).rows.flatten
  end

  {
    ">= '2026-03-01'" => %w[2026-03-15],
    "< '2026-03-01'" => %w[2026-02-28T23:30:00Z 2026-03-01T08:00:00+09:00],
    "> '2026-02-28T23:00:00Z'" => %w[2026-02-28T23:30:00Z 2026-03-15],
    "<= '2026-02-28T23:00:00Z'" => %w[2026-03-01T08:00:00+09:00],
    "= '2026-02-28T23:00:00Z'" => %w[2026-03-01T08:00:00+09:00],
    "!= '2026-02-28T23:00:00Z'" => %w[2026-02-28T23:30:00Z 2026-03-15],
    "= '2026-03-15T00:00:00Z'" => %w[2026-03-15],
    ">= '20260301'" => %w[2026-03-15],
    ">= '2026-03'" => %w[2026-03-15]
  }.each do |condition, expected|
    it "c/context/start_time #{condition} compares instants" do
      expect(starts("#{start} #{condition}", data)).to match_array expected
    end
  end

  it 'reads a parameter the same way' do
    expect(starts("#{start} >= $from", data, from: '2026-03-01')).to eq %w[2026-03-15]
  end

  it 'raises a clear error for a literal that is not ISO 8601' do
    expect { starts("#{start} >= 'yesterday'", data) }
      .to raise_error(OpenEHR::AQL::ExecutionError, /DV_DATE_TIME with 'yesterday'/)
  end

  it 'raises a clear error for a time-only literal' do
    expect { starts("#{start} >= '10:00:00'", data) }
      .to raise_error(OpenEHR::AQL::ExecutionError, /DV_DATE_TIME with '10:00:00'/)
  end

  it 'raises a clear error for a number' do
    expect { starts("#{start} >= 2026", data) }
      .to raise_error(OpenEHR::AQL::ExecutionError, /DV_DATE_TIME/)
  end

  # regression pin: already true before #134. The …/value comparison is
  # a String comparison (#135 is the question of changing it).
  it 'still compares …/value as a String' do
    expect(starts("#{start}/value >= '2026-03-01T00:00:00Z'", data)).to match_array %w[2026-03-01T08:00:00+09:00 2026-03-15]
  end

  describe 'PredicateEvaluator.compare with a DV_DATE' do
    let(:date) { OpenEHR::RM::DataTypes::Quantity::DateTime::DvDate.new(value: '2026-03-15') }

    def compare(left, operator, right) = OpenEHR::AQL::PredicateEvaluator.compare(left, operator, right)

    it 'compares a DV_DATE with a date literal by day' do
      expect([compare(date, '>=', '2026-03-15'), compare(date, '<', '2026-03-15'), compare(date, '=', '2026-03')])
        .to eq [true, false, false]
    end

    it 'treats a partial date literal as its earliest day' do
      expect(compare(date, '>', '2026-03')).to be true
    end

    it 'raises a clear error for a date-time literal against a DV_DATE' do
      expect { compare(date, '>=', '2026-03-15T00:00:00Z') }
        .to raise_error(OpenEHR::AQL::ExecutionError, /DV_DATE\b/)
    end
  end
end
