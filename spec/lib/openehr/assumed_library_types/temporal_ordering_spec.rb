require File.dirname(__FILE__) + '/../../../spec_helper'
require 'openehr/rm/data_types/quantity/date_time'

# #120 (resolution shape (a) bug): the date and date-time classes order
# values by one computation, the calendar count of DvDateTime#magnitude
# (#117). A missing month or day counts as 1 and a missing hour, minute
# or second as 0, inside that computation only (as EHRbase does); the
# value and its string keep their precision. Before #120,
# ISO8601DateTime and ISO8601Date counted nominal 365.24-day years and
# 30.42-day months with a missing month or day as 0, and DvDate raised
# TypeError on a partial value.
describe 'Date/time ordering uses one computation (#120)' do
  def iso_dt(value) = OpenEHR::AssumedLibraryTypes::ISO8601DateTime.new(value)
  def iso_d(value) = OpenEHR::AssumedLibraryTypes::ISO8601Date.new(value)
  def dv_dt(value) = OpenEHR::RM::DataTypes::Quantity::DateTime::DvDateTime.new(value: value)
  def dv_d(value) = OpenEHR::RM::DataTypes::Quantity::DateTime::DvDate.new(value: value)

  describe 'a partial value orders as its earliest instant' do
    it 'ISO8601DateTime: 2026 <=> 2026-01-01 is 0' do
      expect(iso_dt('2026') <=> iso_dt('2026-01-01')).to eq 0
    end

    it 'ISO8601DateTime: 2026-11 <=> 2026-11-01T00:00:00Z is 0' do
      expect(iso_dt('2026-11') <=> iso_dt('2026-11-01T00:00:00Z')).to eq 0
    end

    it 'ISO8601Date: 2026 <=> 2026-01-01 is 0' do
      expect(iso_d('2026') <=> iso_d('2026-01-01')).to eq 0
    end

    # regression pin: already true before #120 (the nominal count also
    # put a missing day before day 2).
    it 'ISO8601Date: 2026-11 orders before 2026-11-02' do
      expect(iso_d('2026-11')).to be < iso_d('2026-11-02')
    end

    it 'DvDate: 2026 <=> 2026-01-01 is 0' do
      expect(dv_d('2026') <=> dv_d('2026-01-01')).to eq 0
    end

    it 'DvDate: 2026-11 has a magnitude and orders before 2026-11-02' do
      expect(dv_d('2026-11')).to be < dv_d('2026-11-02')
    end

    # regression pin: already true before #120 (#117).
    it 'DvDateTime: 2026 <=> 2026-01-01 is 0' do
      expect(dv_dt('2026') <=> dv_dt('2026-01-01')).to eq 0
    end
  end

  it 'ISO8601DateTime: 2026-01-31T12:00:00Z orders before 2026-02-01T00:00:00Z' do
    expect(iso_dt('2026-01-31T12:00:00Z')).to be < iso_dt('2026-02-01T00:00:00Z')
  end

  # Of these, the offset pair (#112) and the two full-date ISO8601Date /
  # DvDate pairs already agreed before #120 (regression pins); the rest
  # were red.
  describe 'the classes agree' do
    [
      %w[2026 2026-01-01],
      %w[2026-11 2026-11-01T00:00:00Z],
      %w[2026-01-31T12:00:00Z 2026-02-01T00:00:00Z],
      %w[2026-12-31T16:00:00Z 2027-01-01T00:00:00Z],
      %w[2026-03-01T10:00:00+09:00 2026-03-01T02:00:00Z]
    ].each do |a, b|
      it "ISO8601DateTime and DvDateTime on #{a} <=> #{b}" do
        expect(iso_dt(a) <=> iso_dt(b)).to eq(dv_dt(a) <=> dv_dt(b))
      end
    end

    [
      %w[2026 2026-01-01],
      %w[2026-11 2026-11-02],
      %w[2026-01-31 2026-02-01],
      %w[2026-12-31 2027-01-01]
    ].each do |a, b|
      it "ISO8601Date and DvDate on #{a} <=> #{b}" do
        expect(iso_d(a) <=> iso_d(b)).to eq(dv_d(a) <=> dv_d(b))
      end
    end
  end

  # regression pin: already true before #120. Ordering equality is not
  # value equality: values of different precision that order the same
  # are == (Comparable), but their value strings differ. Compare #value
  # to tell them apart.
  it 'tells precision apart by #value, not by ==' do
    expect(dv_dt('2026')).to eq dv_dt('2026-01-01')
    expect(dv_dt('2026').value).not_to eq dv_dt('2026-01-01').value
  end

  # regression pin: already true before #120. The count is never written
  # back: the value keeps its precision.
  it 'keeps a partial value as written after comparing it' do
    value = iso_dt('2026-11')
    expect(value <=> iso_dt('2026-11-02')).to eq(-1)
    expect([value.as_string, value.day, value.hour]).to eq ['2026-11', nil, nil]
  end
end
