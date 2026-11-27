require File.dirname(__FILE__) + '/../../../../../../spec_helper'
require 'openehr/rm/data_types/quantity/date_time'

# #113 (resolution shape (c) pin/hardening): a time has no date, so it is
# not normalised to UTC (doing so can cross midnight and leave the order
# undefined). Times with different offsets compare as written. Unlike
# ISO8601DateTime and DvDateTime (#108, #112), the offset is ignored.
describe 'Times with a UTC offset compare as written (#113)' do
  # regression pin: already true before #113.
  it 'orders DvTime 10:00:00+09:00 after 02:00:00Z' do
    dv_time = OpenEHR::RM::DataTypes::Quantity::DateTime::DvTime
    expect(dv_time.new(value: '10:00:00+09:00')).to be > dv_time.new(value: '02:00:00Z')
  end

  # regression pin: already true before #113.
  it 'gives DvTime the same magnitude whatever the offset' do
    dv_time = OpenEHR::RM::DataTypes::Quantity::DateTime::DvTime
    expect(dv_time.new(value: '10:00:00+09:00').magnitude).to eq dv_time.new(value: '10:00:00Z').magnitude
  end

  # regression pin: already true before #113.
  it 'orders ISO8601Time 10:00:00+09:00 after 02:00:00Z' do
    iso_time = OpenEHR::AssumedLibraryTypes::ISO8601Time
    expect(iso_time.new('10:00:00+09:00')).to be > iso_time.new('02:00:00Z')
  end
end
