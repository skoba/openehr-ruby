require File.dirname(__FILE__) + '/../../../spec_helper'
require 'openehr/rm/data_types/quantity/date_time'

# #136 (resolution shape (a) bug; #80 gate A): BASE Foundation Types
# 1.2.0, 6.5.1 valid_iso8601_time, lists times in one form only
# (hh:mm:ss... extended, hhmmss... compact). A time that mixes the two
# (1430:00, 14:3000) was accepted; it is now rejected, as ISO8601Date and
# ISO8601DateTime already reject mixed forms (#80).
describe OpenEHR::AssumedLibraryTypes::ISO8601Time, '.new and .valid_iso8601_time? on mixed forms (#136)' do
  %w[1430:00 14:3000 1430:00.5 14:3000Z 1430:00+09:00].each do |mixed|
    it "rejects #{mixed}" do
      expect { described_class.new(mixed) }.to raise_error ArgumentError
    end

    it "rejects DvTime #{mixed}" do
      expect { OpenEHR::RM::DataTypes::Quantity::DateTime::DvTime.new(value: mixed) }.to raise_error ArgumentError
    end

    it "says #{mixed} is not valid" do
      expect(described_class.valid_iso8601_time?(mixed)).to be_falsey
    end
  end

  # regression pin: single-form times were already accepted before #136.
  %w[14:30:00 14:30 143000 1430 14 14:30:00.5 143000.5 14:30:00Z 143000Z 14:30:00+09:00 143000+0900].each do |value|
    it "accepts #{value}" do
      expect(described_class.new(value).hour).to eq 14
    end

    it "says #{value} is valid" do
      expect(described_class.valid_iso8601_time?(value)).to be true
    end
  end
end
