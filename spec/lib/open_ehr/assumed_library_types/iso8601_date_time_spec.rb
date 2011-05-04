require File.dirname(__FILE__) + '/../../../spec_helper'
include OpenEHR::AssumedLibraryTypes

describe ISO8601DateTime do
  before(:each) do
    @iso8601date_time = ISO8601DateTime.new('2009-06-29T12:34:56.78+0900')
  end

  it 'should be an instance of ISO8601DateTime' do
    @iso8601date_time.should be_an_instance_of ISO8601DateTime
  end

  it 'should be 2009-06-29T12:34:56.78T+09:00 as string' do
    @iso8601date_time.as_string.should == '2009-06-29T12:34:56.78+0900'
  end

  it 'should raise ArgumentError with invalid date format' do
    lambda {
      ISO8601DateTime.new('2009:06:29Z12-34-56')
    }.should raise_error ArgumentError
  end

  it 'should raise ArgumentErrow with empty argument' do
    lambda {
      ISO8601DateTime.new('')
    }.should raise_error ArgumentError
  end    

  it 'allows without fractional second' do
    lambda {
      ISO8601DateTime.new('2009-06-29T12:34:56')
    }.should_not raise_error ArgumentError
  end

  describe 'partial date' do
    it 'should recognize 2009-06' do
      @iso8601date_time.day = nil      
      @iso8601date_time.as_string.should == '2009-06'
    end

    it 'should recognize 2009' do
      @iso8601date_time.day = nil
      @iso8601date_time.month = nil
      @iso8601date_time.as_string.should == '2009'
    end
  end
end
