# frozen_string_literal: true

require File.dirname(__FILE__) + '/../../../spec_helper'

# Issue #59, resolution shape (b) enhancement: a DV_DATE_TIME may be known
# only to the day, the month or the year (e.g. the onset of a problem), and
# is kept at the precision it was entered, with no time of day made up.
# Written red-first against master 9ef603c.
#
# Reading adopted (ruling of 2026-11-24): openEHR BASE Foundation Types
# section 6.2 and the Iso8601_date_time class description allow a partial
# date-time with missing hours, days and months; the class invariants
# (Partial_validity_hour: not hour_unknown, ...) and valid_iso8601_date_time
# do not. This implementation follows the former.
#
# Ordering: a missing part counts as the earliest value it could have
# (month 1, day 1, 00:00:00). Equality follows the ordering (Comparable),
# so values of different precision that denote the same earliest instant
# compare equal; their #value still differs.
describe 'Date-only and date-partial DV_DATE_TIME (#59)' do
  let(:iso) { OpenEHR::AssumedLibraryTypes::ISO8601DateTime }
  let(:dv) { OpenEHR::RM::DataTypes::Quantity::DateTime::DvDateTime }

  describe 'ISO8601DateTime' do
    { '2026-09-22' => [2026, 9, 22], '2026-09' => [2026, 9, nil], '2026' => [2026, nil, nil] }.each do |value, (y, m, d)|
      it "accepts #{value} with no time part" do
        date_time = iso.new(value)
        expect([date_time.year, date_time.month, date_time.day]).to eq([y, m, d])
        expect(date_time.hour_unknown?).to be true
        expect(date_time.as_string).to eq(value)
      end
    end

    %w[2026-09-22T 2026-13 2026-09-31 2026-02-29].each do |value|
      it "still rejects #{value}" do
        expect { iso.new(value) }.to raise_error(ArgumentError)
      end
    end
  end

  describe 'DvDateTime' do
    %w[2026-09-22 2026-09 2026].each do |value|
      it "keeps #{value} at the precision it was entered" do
        date_time = dv.new(value: value)
        expect(date_time.value).to eq(value)
        expect(date_time.as_string).to eq(value)
        expect(date_time.hour).to be_nil
      end
    end

    it 'serializes a date-only value to canonical JSON as entered, in the same shape as a complete value' do
      json = JSON.parse(OpenEHR::Serializer::RMJSONSerializer.new(dv.new(value: '2026-09-22')).serialize)
      complete = JSON.parse(OpenEHR::Serializer::RMJSONSerializer.new(dv.new(value: '2026-09-22T10:00:00')).serialize)
      expect(json['value']).to eq('2026-09-22')
      expect(json.keys).to match_array(complete.keys)
      expect(dv.new(value: json['value']).value).to eq('2026-09-22')
    end

    it 'orders a date-only value as the earliest instant of that day' do
      expect(dv.new(value: '2026-09-22')).to be < dv.new(value: '2026-09-22T00:00:01')
      expect(dv.new(value: '2026-09-22')).to be > dv.new(value: '2026-09-21T23:59:59')
    end

    it 'orders year-only and year-month values as their earliest instant' do
      expect(dv.new(value: '2026')).to be < dv.new(value: '2026-01-01T00:00:01')
      expect(dv.new(value: '2026-09')).to be < dv.new(value: '2026-09-01T00:00:01')
      expect(dv.new(value: '2026')).to be < dv.new(value: '2026-02')
    end

    it 'orders the existing time-partial forms too (they raised TypeError before)' do
      expect(dv.new(value: '2026-09-22T14')).to be < dv.new(value: '2026-09-22T15')
      expect(dv.new(value: '2026-09-22T14:30')).to be < dv.new(value: '2026-09-22T14:31')
    end

    it 'treats values of different precision that denote the same earliest instant as equal' do
      expect(dv.new(value: '2026-09-22')).to eq(dv.new(value: '2026-09-22T00:00:00'))
      expect(dv.new(value: '2026-09')).to eq(dv.new(value: '2026-09-01'))
      expect(dv.new(value: '2026-09-22').value).not_to eq(dv.new(value: '2026-09-22T00:00:00').value)
    end

    it 'keeps the ordering of complete values (regression pin)' do
      # regression pin: complete values ordered the same way before #59.
      expect(dv.new(value: '2026-09-22T14:00:00')).to be < dv.new(value: '2026-09-22T14:00:01')
      expect(dv.new(value: '2026-09-22T14:00:00')).to eq(dv.new(value: '2026-09-22T14:00:00.0'))
    end
  end

  describe 'C_DATE_TIME#valid_value?' do
    let(:validity) { OpenEHR::AM::Archetype::ValidityKind }
    let(:c_date_time) { OpenEHR::AM::Archetype::ConstraintModel::Primitive::CDateTime }

    it 'accepts a date-only value when the hour is optional' do
      constraint = c_date_time.new(second_validity: validity::OPTIONAL, minute_validity: validity::OPTIONAL,
                                   hour_validity: validity::OPTIONAL)
      expect(constraint.valid_value?('2026-09-22')).to be true
    end

    it 'rejects a date-only value when the hour is mandatory (regression pin)' do
      # regression pin: false before #59 too (the value did not parse);
      # now false because hour_validity is MANDATORY.
      constraint = c_date_time.new(hour_validity: validity::MANDATORY)
      expect(constraint.valid_value?('2026-09-22')).to be false
    end

    it 'rejects a year-only value when the month is mandatory' do
      constraint = c_date_time.new(second_validity: validity::OPTIONAL, minute_validity: validity::OPTIONAL,
                                   hour_validity: validity::OPTIONAL, day_validity: validity::OPTIONAL,
                                   month_validity: validity::MANDATORY)
      expect(constraint.valid_value?('2026')).to be false
      expect(constraint.valid_value?('2026-09')).to be true
    end
  end
end
