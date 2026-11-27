require File.dirname(__FILE__) + '/../../../spec_helper'
require 'openehr/rm/data_types/quantity/date_time'

# #121 (resolution shape (a) bug): as_string writes a time to the
# precision it was given, offset included. Before #121 the offset was
# appended only when there was a fractional second, so
# "10:30:15+09:00" came back as "10:30:15".
describe OpenEHR::AssumedLibraryTypes::ISO8601Time, '#as_string keeps the offset (#121)' do
  def round_trip(value) = described_class.new(value).as_string
  def dv_round_trip(value) = OpenEHR::RM::DataTypes::Quantity::DateTime::DvTime.new(value: value).as_string

  context 'with an offset' do
    %w[10:30:15+09:00 10:30-05:00 10+09:00 10:30:15Z].each do |value|
      it "writes #{value} back unchanged" do
        expect(round_trip(value)).to eq value
      end

      it "writes DvTime #{value} back unchanged" do
        expect(dv_round_trip(value)).to eq value
      end
    end
  end

  # regression pin: already true before #121.
  context 'without an offset, or with a fractional second' do
    %w[10 10:30 10:30:15 10:30:15.5 10:30:15.5Z].each do |value|
      it "writes #{value} back unchanged" do
        expect(round_trip(value)).to eq value
      end
    end
  end
end
