require File.dirname(__FILE__) + '/../../../spec_helper'
require 'openehr/rm/data_types/quantity/date_time'

# #112 (resolution shape (a) bug): ISO8601DateTime#<=> compares the UTC
# instant, using the same rule as DvDateTime#magnitude after #108. Before
# #112 it compared the written local time and ignored the offset, so the
# two classes gave opposite answers for the same pair of values.
describe OpenEHR::AssumedLibraryTypes::ISO8601DateTime, '#<=> with a UTC offset (#112)' do
  def iso(value) = described_class.new(value)
  def dv(value) = OpenEHR::RM::DataTypes::Quantity::DateTime::DvDateTime.new(value: value)

  {
    '2026-03-01T10:00:00+09:00' => '2026-03-01T01:00:00Z',
    '2026-03-01T10:00:00+0900' => '2026-03-01T01:00:00Z',
    '2026-03-01T10:00:00+05:30' => '2026-03-01T04:30:00Z',
    '2026-03-01T10:00:00-05:00' => '2026-03-01T15:00:00Z',
    '2026-03-01T10:00:00-03:30' => '2026-03-01T13:30:00Z',
    '2026-03-01T10:00:00-00:30' => '2026-03-01T10:30:00Z',
    '2026-03-02T03:00:00+09:00' => '2026-03-01T18:00:00Z'
  }.each do |local, utc|
    it "#{local} equals #{utc}" do
      expect(iso(local) <=> iso(utc)).to eq 0
    end
  end

  it 'orders 10:00+09:00 before 02:00Z on the same day' do
    expect(iso('2026-03-01T10:00:00+09:00')).to be < iso('2026-03-01T02:00:00Z')
  end

  [
    %w[2026-03-01T10:00:00+09:00 2026-03-01T02:00:00Z],
    %w[2026-03-01T10:00:00-05:00 2026-03-01T14:00:00Z],
    %w[2026-03-01T10:00:00-03:30 2026-03-01T13:00:00Z],
    %w[2026-03-01T10:00:00-00:30 2026-03-01T10:15:00Z],
    %w[2026-03-01T10:00:00+0900 2026-03-01T01:00:00Z],
    %w[2026-03-01T10:00:00+09:00 2026-03-01T02:00:00]
  ].each do |a, b|
    it "agrees with DvDateTime on #{a} <=> #{b}" do
      expect(iso(a) <=> iso(b)).to eq(dv(a) <=> dv(b))
    end
  end

  # A value without an offset counts as UTC, as in DvDateTime (#108). So
  # when only one side has an offset, the other side is read as UTC.
  it 'reads a value without an offset as UTC when the other has one' do
    expect(iso('2026-03-01T10:00:00+09:00') <=> iso('2026-03-01T01:00:00')).to eq 0
  end

  # regression pin: already true before #112.
  it 'treats no offset and Z as the same instant' do
    expect(iso('2026-03-01T10:00:00') <=> iso('2026-03-01T10:00:00Z')).to eq 0
  end

  # regression pin: already true before #112.
  it 'orders two values without an offset by their written time' do
    expect(iso('2026-03-01T09:00:00')).to be < iso('2026-03-01T10:00:00')
  end
end
