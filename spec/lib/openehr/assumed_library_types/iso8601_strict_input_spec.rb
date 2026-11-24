# frozen_string_literal: true

require File.dirname(__FILE__) + '/../../../spec_helper'

# Issue #72, resolution shape (a) bug: ISO8601DateTime (and ISO8601Date)
# matched their input with an unanchored regular expression, so any string
# that merely contained a date(-time) was accepted and the rest silently
# dropped. Written red-first against master 273224c.
describe 'OpenEHR::AssumedLibraryTypes strict ISO 8601 input (#72)' do
  let(:date_time) { OpenEHR::AssumedLibraryTypes::ISO8601DateTime }
  let(:date) { OpenEHR::AssumedLibraryTypes::ISO8601Date }

  describe 'ISO8601DateTime' do
    { 'x2026-09-22T14:30:00' => 'leading garbage', '2026-09-22T14:30:00zz' => 'trailing garbage',
      '2026-09-22T14:30:00+09:00junk' => 'trailing garbage', ' 2026-09-22T14' => 'leading whitespace',
      "2026-09-22T14\n" => 'a trailing newline', '2026T14' => 'an hour without a complete date',
      '2026-09T14' => 'an hour without a complete date' }.each do |value, reason|
      it "rejects #{reason}: #{value.inspect}" do
        expect { date_time.new(value) }.to raise_error(ArgumentError)
      end
    end

    it 'rejects the compact form instead of misreading it (it used to parse 20260922T143000 as year 0922)' do
      expect { date_time.new('20260922T143000') }.to raise_error(ArgumentError)
    end

    ['2026-09-22T14', '2026-09-22T14:30', '2026-09-22T14:30:05', '2026-09-22T14:30:05.25', '2026-09-22T14:30:05Z',
     '2026-09-22T14:30:05+09:00', '2026-09-22T14:30:05.5+09:00', '2026-09-22T14:30-0500'].each do |value|
      it "still accepts #{value} (regression pin)" do
        # regression pin: complete and time-partial forms are unchanged.
        expect { date_time.new(value) }.not_to raise_error
        expect(date_time.new(value).hour).to eq(14)
      end
    end
  end

  describe 'ISO8601Date' do
    ['x2026-09-22', '2026-09-22zz', '2026-09-22T10:00:00', '2026-9-22', ' 2026'].each do |value|
      it "rejects #{value.inspect}" do
        expect { date.new(value) }.to raise_error(ArgumentError)
      end
    end

    %w[2026 2026-09 2026-09-22].each do |value|
      it "still accepts #{value} (regression pin)" do
        # regression pin: complete and partial dates are unchanged.
        expect(date.new(value).as_string).to eq(value)
      end
    end
  end
end
