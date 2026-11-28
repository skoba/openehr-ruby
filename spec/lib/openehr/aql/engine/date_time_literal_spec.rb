require File.dirname(__FILE__) + '/../../../../spec_helper'
require File.dirname(__FILE__) + '/../fixtures/blood_pressure_builder'

# #134 (resolution shape (a) bug): AQL (QUERY 3.12.5) compares a
# date-time path itself with a quoted ISO 8601 literal. Before #134 that
# raised NoMethodError (DvQuantified#<=> called magnitude on the String).
# #161 (R-20261128-11) then changed how the two compare: by the written
# components, equal down to the common precision, offsets applied only
# when both sides have one (date_time_components_spec.rb). The examples
# whose result #161 changed say what #134 gave. Plans:
# docs/design/134-aql-date-time-literal-plan.md,
# docs/design/135-aql-value-instant-plan.md.
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
    # #134 (by instant): %w[2026-03-15]
    ">= '2026-03-01'" => %w[2026-03-01T08:00:00+09:00 2026-03-15],
    # #134 (by instant): %w[2026-02-28T23:30:00Z 2026-03-01T08:00:00+09:00]
    "< '2026-03-01'" => %w[2026-02-28T23:30:00Z],
    "> '2026-02-28T23:00:00Z'" => %w[2026-02-28T23:30:00Z 2026-03-15],
    "<= '2026-02-28T23:00:00Z'" => %w[2026-03-01T08:00:00+09:00],
    "= '2026-02-28T23:00:00Z'" => %w[2026-03-01T08:00:00+09:00],
    "!= '2026-02-28T23:00:00Z'" => %w[2026-02-28T23:30:00Z 2026-03-15],
    "= '2026-03-15T00:00:00Z'" => %w[2026-03-15],
    # #134 (by instant): %w[2026-03-15] for both
    ">= '20260301'" => %w[2026-03-01T08:00:00+09:00 2026-03-15],
    ">= '2026-03'" => %w[2026-03-01T08:00:00+09:00 2026-03-15]
  }.each do |condition, expected|
    it "c/context/start_time #{condition} compares the written components" do
      expect(starts("#{start} #{condition}", data)).to match_array expected
    end
  end

  # #134 (by instant): %w[2026-03-15]
  it 'reads a parameter the same way' do
    expect(starts("#{start} >= $from", data, from: '2026-03-01')).to match_array %w[2026-03-01T08:00:00+09:00 2026-03-15]
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

    # #134: = '2026-03' was false (the literal was its earliest day).
    it 'compares a DV_DATE with a date literal by day' do
      expect([compare(date, '>=', '2026-03-15'), compare(date, '<', '2026-03-15'), compare(date, '=', '2026-03')])
        .to eq [true, false, true]
    end

    # #134: true (the literal was its earliest day, 2026-03-01).
    it 'treats a partial date literal as equal down to its month' do
      expect(compare(date, '>', '2026-03')).to be false
    end

    # #134: raised ExecutionError (a date-time literal against a DV_DATE).
    it 'compares a DV_DATE with a date-time literal by the date' do
      expect(compare(date, '>=', '2026-03-15T00:00:00Z')).to be true
    end
  end
end
