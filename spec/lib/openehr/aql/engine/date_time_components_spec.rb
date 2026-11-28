# frozen_string_literal: true

require File.dirname(__FILE__) + '/../../../../spec_helper'
require File.dirname(__FILE__) + '/../fixtures/blood_pressure_builder'

# #161 (R-20261128-11), resolution shape (a) bug: AQL compares a
# DV_DATE_TIME or DV_DATE value with a date or date-time by the written
# components, from the year, only those both sides have; equal down to
# the common precision is equal; offsets are applied only when both
# sides have one. #134 (unreleased) compared earliest instants with a
# missing offset read as UTC. Plan: docs/design/135-aql-value-instant-plan.md.
# The examples are the ruling's, the record value on the left. Red first
# against master 0f21160: 16 of the 32 examples failed; the rest already
# gave the decided answer under #134 (the two rules agree there).
describe 'AQL: date-time values compare by written components (#161)' do
  let(:builder) { OpenEHR::AQL::Fixtures::BloodPressureBuilder }

  def dv_date_time(value) = OpenEHR::RM::DataTypes::Quantity::DateTime::DvDateTime.new(value: value)
  def dv_date(value) = OpenEHR::RM::DataTypes::Quantity::DateTime::DvDate.new(value: value)

  # Runs the condition through the engine against one composition whose
  # context/start_time is the record value.
  def matches?(record, condition)
    data = OpenEHR::AQL::Dataset.of_compositions(
      [builder.blood_pressure_composition(systolic: 120, diastolic: 80, start_time: record)]
    )
    where = condition.gsub('S ', 'c/context/start_time ')
    !OpenEHR::AQL.execute("SELECT c/context/start_time/value FROM EHR e CONTAINS COMPOSITION c WHERE #{where}", data)
                 .rows.empty?
  end

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

  describe 'PredicateEvaluator.compare' do
    def compare(left, operator, right) = OpenEHR::AQL::PredicateEvaluator.compare(left, operator, right)

    it 'compares a DV_DATE with a date-time literal (DV_DATE 2026-03-01 = 2026-03-01T12:00:00)' do
      expect(compare(dv_date('2026-03-01'), '=', '2026-03-01T12:00:00')).to be true
    end

    it 'compares two date-time values (path to path) by the same rule' do
      expect([compare(dv_date_time('2026-11'), '=', dv_date_time('2026-11-15T10:00:00Z')),
              compare(dv_date_time('2026-03-01T08:00:00+09:00'), '<', dv_date_time('2026-03-01T00:00:00Z')),
              compare(dv_date('2026-03-01'), '=', dv_date_time('2026-03-01T12:00:00Z'))])
        .to eq [true, true, true]
    end

    it 'gives = and != opposite answers on a common-precision tie' do
      expect([compare(dv_date('2026-11-15'), '=', '2026-11'), compare(dv_date('2026-11-15'), '!=', '2026-11')])
        .to eq [true, false]
    end

    # regression pin: unreadable literals already raised (#134).
    it "still raises for 'abc' and a time-only literal (regression pin)" do
      expect { compare(dv_date_time('2026-11'), '>=', 'abc') }.to raise_error(OpenEHR::AQL::ExecutionError, /'abc'/)
      expect { compare(dv_date('2026-11-01'), '>=', '14:30') }.to raise_error(OpenEHR::AQL::ExecutionError, /'14:30'/)
    end
  end

  describe 'ORDER BY' do
    def ordered(direction = '')
      data = OpenEHR::AQL::Dataset.of_compositions(
        ['2026-11-01T00:00:00Z', '2026-11', '2026-11-01', '2026-10-31T23:00:00Z'].map do |t|
          builder.blood_pressure_composition(systolic: 120, diastolic: 80, start_time: t)
        end
      )
      OpenEHR::AQL.execute(
        "SELECT c/context/start_time/value FROM EHR e CONTAINS COMPOSITION c ORDER BY c/context/start_time #{direction}",
        data
      ).rows.flatten
    end

    it 'orders by earliest instant, then the coarser value first' do
      expect(ordered).to eq %w[2026-10-31T23:00:00Z 2026-11 2026-11-01 2026-11-01T00:00:00Z]
    end

    it 'reverses that order for DESC' do
      expect(ordered('DESC')).to eq %w[2026-11-01T00:00:00Z 2026-11-01 2026-11 2026-10-31T23:00:00Z]
    end
  end

  # regression pin: the RM types keep their total order (#117, #120).
  it 'leaves DvDateTime#<=> as it was (regression pin)' do
    expect(dv_date_time('2026-11') <=> dv_date_time('2026-11-15')).to eq(-1)
  end
end
