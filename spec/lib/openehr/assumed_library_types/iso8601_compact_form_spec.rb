require File.dirname(__FILE__) + '/../../../spec_helper'
require 'openehr/rm/data_types/quantity/date_time'

# #80 (resolution shape (b) enhancement): the ISO 8601 compact forms
# BASE Foundation Types 1.2.0 lists (6.5.1 valid_iso8601_date,
# valid_iso8601_date_time) are read, to the same fields as their
# extended equivalents. as_string returns the extended form (6.5.4,
# 6.5.6); a DV_ value keeps the string it was given. is_extended? tells
# which form was given (6.5.3-6.5.6). A value that mixes the two forms
# is not one the specification lists and is rejected (date, date-time).
# Plan: docs/design/80-iso8601-compact-plan.md.
describe 'ISO 8601 compact form (#80)' do
  def fields(value)
    [value.year, value.month, value.day, value.hour, value.minute, value.second, value.fractional_second,
     value.timezone]
  end

  def date_fields(value) = [value.year, value.month, value.day]

  describe OpenEHR::AssumedLibraryTypes::ISO8601Date do
    { '20260922' => '2026-09-22', '202609' => '2026-09' }.each do |compact, extended|
      it "reads #{compact} as #{extended}" do
        expect(date_fields(described_class.new(compact))).to eq date_fields(described_class.new(extended))
      end

      it "writes #{compact} back in the extended form" do
        expect(described_class.new(compact).as_string).to eq extended
      end

      it "says #{compact} is not extended" do
        expect(described_class.new(compact).is_extended?).to be false
      end
    end

    # regression pin: already true before #80.
    it 'says an extended date is extended' do
      expect(described_class.new('2026-09-22').is_extended?).to be true
    end

    # regression pin: already rejected before #80.
    %w[2026-0922 202609-22].each do |mixed|
      it "rejects the mixed form #{mixed}" do
        expect { described_class.new(mixed) }.to raise_error ArgumentError
      end
    end
  end

  describe OpenEHR::AssumedLibraryTypes::ISO8601DateTime do
    {
      '20260922T143000' => '2026-09-22T14:30:00',
      '20260922T1430' => '2026-09-22T14:30',
      '20260922T14' => '2026-09-22T14',
      '20260922T143000.5Z' => '2026-09-22T14:30:00.5Z',
      '20260922T143000,5Z' => '2026-09-22T14:30:00.5Z',
      '20260922T143000+0900' => '2026-09-22T14:30:00+0900',
      '20260922' => '2026-09-22',
      '202609' => '2026-09'
    }.each do |compact, extended|
      it "reads #{compact} as #{extended}" do
        expect(fields(described_class.new(compact))).to eq fields(described_class.new(extended))
      end

      it "says #{compact} is not extended" do
        expect(described_class.new(compact).is_extended?).to be false
      end
    end

    it 'writes 20260922T143000 back as 2026-09-22T14:30:00' do
      expect(described_class.new('20260922T143000').as_string).to eq '2026-09-22T14:30:00'
    end

    it 'orders a compact value with its extended equivalent' do
      expect(described_class.new('20260922T143000Z') <=> described_class.new('2026-09-22T14:30:00Z')).to eq 0
    end

    # regression pin: already true before #80.
    it 'says an extended date-time is extended' do
      expect(described_class.new('2026-09-22T14:30:00').is_extended?).to be true
    end

    # regression pin: already rejected before #80. The date part and the
    # time part (and a compact value's offset) use one form.
    %w[2026-09-22T143000 20260922T14:30:00 20260922T143000+09:00].each do |mixed|
      it "rejects the mixed form #{mixed}" do
        expect { described_class.new(mixed) }.to raise_error ArgumentError
      end
    end
  end

  describe OpenEHR::AssumedLibraryTypes::ISO8601Time do
    it 'says 143000 is not extended' do
      expect(described_class.new('143000').is_extended?).to be false
    end

    # regression pin: compact times were already read, and written back
    # in the extended form, before #80.
    it 'reads 143000 as 14:30:00' do
      expect(described_class.new('143000').as_string).to eq '14:30:00'
    end
  end

  describe 'DV_ classes keep the string they were given' do
    it 'DvDateTime' do
      dt = OpenEHR::RM::DataTypes::Quantity::DateTime::DvDateTime.new(value: '20260922T143000Z')
      expect([dt.value, dt.as_string, dt.is_extended?]).to eq ['20260922T143000Z', '2026-09-22T14:30:00Z', false]
    end

    it 'DvDate' do
      date = OpenEHR::RM::DataTypes::Quantity::DateTime::DvDate.new(value: '20260922')
      expect([date.value, date.as_string, date.is_extended?]).to eq ['20260922', '2026-09-22', false]
    end

    # The form is read back from #value, so the JSON carries only value.
    it 'serializes a compact DvDateTime to JSON with its value only' do
      dt = OpenEHR::RM::DataTypes::Quantity::DateTime::DvDateTime.new(value: '20260922T143000Z')
      json = JSON.parse(OpenEHR::Serializer::RMJSONSerializer.new(dt).serialize)
      expect(json).to eq('_type' => 'DV_DATE_TIME', 'value' => '20260922T143000Z', 'magnitude_status' => '=')
    end

    it 'DvTime' do
      time = OpenEHR::RM::DataTypes::Quantity::DateTime::DvTime.new(value: '143000')
      expect([time.value, time.as_string, time.is_extended?]).to eq ['143000', '14:30:00', false]
    end
  end
end
