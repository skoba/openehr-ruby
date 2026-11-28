# frozen_string_literal: true

require File.dirname(__FILE__) + '/../../../../spec_helper'
require File.dirname(__FILE__) + '/../fixtures/blood_pressure_builder'

# #135 (R-20261128-11), resolution shape (b) enhancement: …/value of a
# DV_DATE_TIME or DV_DATE compares and orders by the same rule as the
# value itself (#161, date_time_components_spec.rb), instead of as a
# String. LIKE and MATCHES still see the String. The examples are the
# ruling's, the record value on the left, with S standing for
# c/context/start_time/value. Plan: docs/design/135-aql-value-instant-plan.md.
describe 'AQL: …/value of a date-time compares by written components (#135)' do
  let(:builder) { OpenEHR::AQL::Fixtures::BloodPressureBuilder }

  def data(*records)
    OpenEHR::AQL::Dataset.of_compositions(
      records.map { |t| builder.blood_pressure_composition(systolic: 120, diastolic: 80, start_time: t) }
    )
  end

  def rows(where, records, params = {})
    OpenEHR::AQL.execute(
      "SELECT c/context/start_time/value FROM EHR e CONTAINS COMPOSITION c WHERE #{where}", data(*records), params: params
    ).rows.flatten
  end

  def matches?(record, condition) = !rows(condition.gsub('S ', 'c/context/start_time/value '), [record]).empty?

  [
    ['2026-11', "S > '2026-10-30'", true],
    ['2026-11', "S = '2026-11-15'", true],
    ['2026-11-15', "S = '2026-11'", true],
    ['2026-11-15', "S > '2026-11'", false],
    ['2026-11', "S >= '2026-11-15'", true],
    ['2026-11', "S > '2026-11-15'", false],
    ['2026-11', "S >= '2026-11-10' AND S < '2026-11-20'", false],
    ['2026-11', "S >= '2026-11-10' AND S <= '2026-11-20'", true],
    ['2025', "S >= '2025-01-01' AND S < '2026-01-01'", true],
    ['2026', "S >= '2025-01-01' AND S < '2026-01-01'", false],
    ['2025', "S = '2025'", true],
    ['2025-03', "S = '2025'", true],
    ['2025-03-10', "S = '2025'", true],
    ['2025-03-10T08:00:00+09:00', "S = '2025'", true],
    ['2026-03-01T08:00:00+09:00', "S >= '2026-03-01'", true],
    ['2026-02-28T23:00:00Z', "S >= '2026-03-01'", false],
    ['2026-03-01T08:00:00+09:00', "S = '2026-02-28T23:00:00Z'", true],
    ['2026-03-01T08:00:00+09:00', "S >= '2026-03-01T00:00:00Z'", false],
    ['2026-03-01T08:00:00', "S >= '2026-03-01T00:00:00Z'", true],
    ['2026-03-15', "S >= '2026-03-15T00:00:00Z'", true],
    ['2026-03-15', "S > '2026-03-15T00:00:00Z'", false],
    ['2026-03-01T08:30+09:00', "S = '2026-02-28T23:30:45Z'", true],
    ['2026-03-01T08:00:00', "S < '2026-03-01T08:00:00.5'", true],
    ['2026-11-15T10:00:00+09:00', "S = '20261115'", true],
    ['2026-03-01T03:00:00-05:00', "S = '2026-03-01T08:00:00Z'", true]
  ].each do |record, condition, expected|
    it "#{record}: #{condition} #{expected ? 'matches' : 'does not match'}" do
      expect(matches?(record, condition)).to be expected
    end
  end

  it 'compares …/value with a parameter the same way' do
    expect(rows('c/context/start_time/value = $month', ['2026-11-15T10:00:00Z', '2026-10-31'], month: '2026-11'))
      .to eq ['2026-11-15T10:00:00Z']
  end

  it 'raises for a literal that is not a date or date-time' do
    expect { rows("c/context/start_time/value >= 'abc'", ['2026-11']) }
      .to raise_error(OpenEHR::AQL::ExecutionError, /'abc'/)
  end

  it 'compares …/value with the value itself (path to path)' do
    expect(rows('c/context/start_time/value = c/context/start_time', ['2026-11'])).to eq ['2026-11']
  end

  it 'orders ORDER BY …/value like the value itself' do
    records = ['2026-11-01T00:00:00Z', '2026-03-01T08:00:00+09:00', '2026-11', '2026-02-28T23:30:00Z', '2026-11-01']
    expect(OpenEHR::AQL.execute(
      'SELECT c/context/start_time/value FROM EHR e CONTAINS COMPOSITION c ORDER BY c/context/start_time/value',
      data(*records)
    ).rows.flatten).to eq %w[2026-03-01T08:00:00+09:00 2026-02-28T23:30:00Z 2026-11 2026-11-01 2026-11-01T00:00:00Z]
  end

  # regression pin: LIKE has always compared the String as written.
  it 'still matches LIKE against the written String (regression pin)' do
    expect(rows("c/context/start_time/value LIKE '2026-03-01T08*'", ['2026-03-01T08:00:00+09:00', '2026-02-28T23:30:00Z']))
      .to eq ['2026-03-01T08:00:00+09:00']
  end

  # The comparison uses the owner; SELECT still returns the String.
  it 'selects …/value as the written String while WHERE compares the owner' do
    expect(rows("c/context/start_time/value = '2026'", ['2026-03-01T08:00:00+09:00'])).to eq ['2026-03-01T08:00:00+09:00']
  end
end
