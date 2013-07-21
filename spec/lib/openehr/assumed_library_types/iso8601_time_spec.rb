require File.dirname(__FILE__) + '/../../../spec_helper'
include OpenEHR::AssumedLibraryTypes

describe ISO8601Time do
  before(:each) do
    @iso8601time = ISO8601Time.new('15:55:37.32+0900')
  end

  it 'should be an instance of ISO8601Time' do
    @iso8601time.should be_an_instance_of ISO8601Time
  end

  it 's hour should be 15' do
    @iso8601time.hour.should == 15
  end

  it 's minute should be 55' do
    @iso8601time.minute.should == 55
  end

  it 's second should be 37'do
    @iso8601time.second.should == 37
  end

  it 's fractional second should be 0.32' do
    @iso8601time.fractional_second == 0.32
  end

  it 'have fractional_second' do
    @iso8601time.should have_fractional_second
  end

  it 's time zone should +0900' do
    @iso8601time.timezone == '+0900'
  end

  it 'should be 15:55:37.32+0900 as_string' do
    @iso8601time.as_string.should == '15:55:37.32+0900'
  end

  it 'decimal sign should not be comma' do
    @iso8601time.is_decimal_sign_comma?.should_not be_true
  end

  it 'should be extended' do
    @iso8601time.is_extended?.should be_true
  end

  it 'should not be partial' do
    @iso8601time.is_partial?.should_not be true
  end

  describe 'hour behavior' do
    it 'should raise ArgumentError with nil hour' do
      lambda {
        @iso8601time.hour = nil
      }.should raise_error ArgumentError
    end

    it 'should not raise ArgumentError with -1 hour' do
      lambda {
        @iso8601time.hour = -1
      }.should raise_error ArgumentError
    end        

    it 'should not raise ArgumentError with 0 hour' do
      expect {
        @iso8601time.hour = 0
      }.not_to raise_error
    end

    it 'should not raise ArgumentError with 23 hour' do
      expect {
        @iso8601time.hour = 23
      }.not_to raise_error
    end

    it 'should not raise ArgumentError with 24 hour' do
      expect {
        @iso8601time.hour = 24
      }.to raise_error ArgumentError
    end
  end

  describe 'minute behavior' do
    it 'should raise ArgumentError with -1 miniute' do
      expect {
        @iso8601time.minute = -1
      }.to raise_error ArgumentError
    end

    it 'should not raise ArgumentError with 0 minute' do
      expect {
        @iso8601time.minute = 0
      }.not_to raise_error
    end

    it 'should not raise ArgumentError with 59 minute' do
      expect {
        @iso8601time.minute = 59
      }.not_to raise_error
    end

    it 'should raise ArgumentError with 60 minute' do
      expect {
        @iso8601time.minute = 60
      }.to raise_error ArgumentError
    end
  end

  describe 'second behavior' do
    it 'should raise ArgumentError with -1 miniute' do
      expect {
        @iso8601time.second = -1
      }.to raise_error ArgumentError
    end

    it 'should not raise ArgumentError with 0 second' do
      expect {
        @iso8601time.second = 0
      }.not_to raise_error
    end

    it 'should not raise ArgumentError with 59 second' do
      expect {
        @iso8601time.second = 59
      }.not_to raise_error
    end

    it 'should raise ArgumentError with 60 second' do
      expect {
        @iso8601time.second = 60
      }.to raise_error ArgumentError
    end
  end

  describe 'fractional second behavior' do
    it 'should raise ArgumentError less than -0.0' do
      expect {
        @iso8601time.fractional_second = -0.1
      }.to raise_error ArgumentError
    end

    it 'should raise ArgumentError more than 1.0' do
      expect {
        @iso8601time.fractional_second = 1.0
      }.to raise_error ArgumentError
    end
  end

  describe 'timezone behavior' do
    it 'should raise ArgumentError with invalid timezone' do
      expect {
        @iso8601time.timezone = '+AbD:111'
      }.to raise_error ArgumentError
    end

    it 'should allow ArgumentError with nil timezone' do
      expect {
        @iso8601time.timezone = nil
      }.not_to raise_error
    end
  end

  describe 'constructor behavior' do
    it 'should_not raise ArgumentError with 21:18:09.01' do
      expect {
        ISO8601Time.new('21:18:09.01')
      }.not_to raise_error
    end

    it 'should_not raise ArgumentError with 21:18:09' do
      expect {
        ISO8601Time.new('21:18:09')
      }.not_to raise_error
    end

    it 'should_not raise ArgumentError with 21:18' do
      expect {
        ISO8601Time.new('21:18')
      }.not_to raise_error
    end

    it 'should_not raise ArgumentError with 21' do
      expect {
        ISO8601Time.new('21')
      }.not_to raise_error
    end

    it 'should raise ArgumentError with malformation' do
      expect {
        ISO8601Time.new('ABDCD')
      }.to raise_error ArgumentError
    end
  end

  describe 'ISO8601 time validation' do
    it 'should be valid iso8601 Time' do
      ISO8601Time.should be_valid_iso8601_time '21:24:30.05+09:00'
    end

    it 'should not be valid with over 24 hour' do
      ISO8601Time.should_not be_valid_iso8601_time '24:24:30.05+09:00'
    end

    it 'should be valid with over 24:00:00' do
      ISO8601Time.should be_valid_iso8601_time '24:00:00.00'
    end

    it 'should not vaild with under 0 hour' do
      ISO8601Time.should_not be_valid_iso8601_time '-1:24:30.05+09:00'
    end

    it 'should not valid with more than 60 minutes' do
      ISO8601Time.should_not be_valid_iso8601_time '21:60:30'
    end

    it 'should not valid with more than 60 seconds' do
      ISO8601Time.should_not be_valid_iso8601_time '21:34:60'
    end

    it 'should not valid with invalid hour in timezone' do
      ISO8601Time.should_not be_valid_iso8601_time '21:24:30.05+24:00'
    end

    it 'should not valid with invalid minute in timezone' do
      ISO8601Time.should_not be_valid_iso8601_time '21:24:30.05+22:60'
    end

    it 'should not valid with invalid minute in timezone' do
      ISO8601Time.should_not be_valid_iso8601_time '21:24:30.05TAABZ'
    end
  end
end
