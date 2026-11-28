# frozen_string_literal: true

require File.dirname(__FILE__) + '/../../../spec_helper'

# #141, resolution shape (a) bug: valid_iso8601_time? rejected every
# negative UTC offset, because valid_timezone_part? checked the signed
# hour of Timezone ('-05'.to_i is -5) against 0. Written red-first
# against master 013fa6d.
describe 'OpenEHR::AssumedLibraryTypes::ISO8601Time.valid_iso8601_time? with a negative offset (#141)' do
  def valid?(value) = OpenEHR::AssumedLibraryTypes::ISO8601Time.valid_iso8601_time?(value)

  %w[14:30:00-05:00 14:30-0500 14:30:00-03:30 143000-0500 14:30:00-05].each do |value|
    it "accepts #{value}" do
      expect(valid?(value)).to be true
    end
  end

  %w[14:30:00-24:00 14:30:00+24:00 14:30:00-05:60 14:30:00+05:60].each do |value|
    # regression pin: an offset hour of 24 or more, or minutes of 60 or
    # more, was already rejected in the positive direction; the negative
    # direction was rejected for every offset.
    it "still rejects #{value} (regression pin)" do
      expect(valid?(value)).to be false
    end
  end

  context 'with a positive offset or Z' do
    %w[14:30:00+05:00 14:30:00Z 14:30:00+09].each do |value|
      it "still accepts #{value} (regression pin)" do
        # regression pin: positive offsets and Z were already accepted.
        expect(valid?(value)).to be true
      end
    end
  end
end
