require File.dirname(__FILE__) + '/../../../../../../spec_helper'
require 'openehr/rm/data_types/quantity/date_time'

# #108 (resolution shape (a) bug): magnitude is the UTC instant, so a
# value with an offset equals the same instant written with Z, and
# values with different offsets order by their instant. Before #108 a
# positive offset was added instead of subtracted, a negative offset's
# minutes went the wrong way, and "-00:30" lost its sign.
describe OpenEHR::RM::DataTypes::Quantity::DateTime::DvDateTime, '#magnitude with a UTC offset (#108)' do
  def dt(value) = described_class.new(value: value)

  # Before #108, -05:00 was already right, and -00:30 came out right only
  # because its lost sign sent it down the (wrong) positive branch.
  {
    '2026-03-01T10:00:00+09:00' => '2026-03-01T01:00:00Z',
    '2026-03-01T10:00:00+0900' => '2026-03-01T01:00:00Z',
    '2026-03-01T10:00:00+05:30' => '2026-03-01T04:30:00Z',
    '2026-03-01T10:00:00-05:00' => '2026-03-01T15:00:00Z',
    '2026-03-01T10:00:00-03:30' => '2026-03-01T13:30:00Z',
    '2026-03-01T10:00:00-00:30' => '2026-03-01T10:30:00Z',
    # Across a day boundary, within a month (magnitude uses nominal
    # month lengths, so a month boundary is not compared here).
    '2026-03-02T03:00:00+09:00' => '2026-03-01T18:00:00Z'
  }.each do |local, utc|
    it "#{local} has the magnitude of #{utc}" do
      expect(dt(local).magnitude).to be_within(0.001).of(dt(utc).magnitude)
    end
  end

  it 'orders 10:00+09:00 (01:00Z) before 11:00Z, as in the downstream report' do
    expect(dt('2026-03-01T10:00:00+09:00') <=> dt('2026-03-01T11:00:00Z')).to eq(-1)
  end

  it 'orders 10:00-05:00 (15:00Z) after 12:00Z (regression pin)' do
    # regression pin: a negative whole-hour offset was already right before #108.
    expect(dt('2026-03-01T10:00:00-05:00') <=> dt('2026-03-01T12:00:00Z')).to eq(1)
  end

  it 'keeps the magnitude of a value without an offset, or with Z (regression pin)' do
    # regression pin: no offset and Z were already right before #108.
    expect(dt('2009-09-29T15:03:22.3Z').magnitude).to be_within(0.01).of(63423697018.3)
    expect(dt('2009-09-29T15:03:22.3').magnitude).to be_within(0.01).of(63423697018.3)
  end
end
