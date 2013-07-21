require File.dirname(__FILE__) + '/../../../spec_helper'
include OpenEHR::AssumedLibraryTypes

describe ISO8601Duration do
  before(:each) do
    @iso8601duration = ISO8601Duration.new('P1Y2M3W4DT5H6M7.8S')
  end

  it 'should be an instance of ISO8601Duration' do
    @iso8601duration.should be_an_instance_of ISO8601Duration
  end

  it 'years should be 1' do
    @iso8601duration.years.should be_equal 1
  end

  it 'months should be 2' do
    @iso8601duration.months.should be_equal 2
  end

  it 'weeks should be 3' do
    @iso8601duration.weeks.should be_equal 3
  end

  it 'days should be 4' do
    @iso8601duration.days.should be_equal 4
  end

  it 'hours should be 5' do
    @iso8601duration.hours.should be_equal 5
  end

  it 'minutes should be 6' do
    @iso8601duration.minutes.should be_equal 6
  end

  it 'seconds should be 7' do
    @iso8601duration.seconds.should be_equal 7
  end

  it 'fractional_seconds should be .8' do
    @iso8601duration.fractional_second.should == 0.8
  end

  it 'should be equal P1Y2M3W4DT5H6M7.8S as string' do
    @iso8601duration.as_string.should == 'P1Y2M3W4DT5H6M7.8S'
  end

  it 'should not raise ArgumentError with 0 yaers' do
    expect {
      @iso8601duration.years = 0
    }.not_to raise_error
  end

  it 'should raise ArgumentError with -1 yaers' do
    expect {
      @iso8601duration.years = -1
    }.to raise_error ArgumentError
  end

  it 'should not raise ArgumentError with 0 months' do
    expect {
      @iso8601duration.months = 0
    }.not_to raise_error
  end

  it 'should raise ArgumentError with -1 months' do
    expect {
      @iso8601duration.months = -1
    }.to raise_error ArgumentError
  end
    
  it 'should not raise ArgumentError with 0 weeks' do
    expect {
      @iso8601duration.weeks = 0
    }.not_to raise_error
  end

  it 'should raise ArgumentError with -1 weeks' do
    expect {
      @iso8601duration.weeks = -1
    }.to raise_error ArgumentError
  end

  it 'should not raise ArgumentError with 0 days' do
    expect {
      @iso8601duration.days = 0
    }.not_to raise_error
  end

  it 'should raise ArgumentError with -1 days' do
    expect {
      @iso8601duration.days = -1
    }.to raise_error ArgumentError
  end

  it 'should not raise ArgumentError with 0 hours' do
    expect {
      @iso8601duration.hours = 0
    }.not_to raise_error
  end

  it 'should raise ArgumentError with -1 hours' do
    expect {
      @iso8601duration.hours = -1
    }.to raise_error ArgumentError
  end

  it 'should not raise ArgumentError with 0 minutes' do
    expect {
      @iso8601duration.minutes = 0
    }.not_to raise_error
  end

  it 'should raise ArgumentError with -1 minutes' do
    expect {
      @iso8601duration.minutes = -1
    }.to raise_error ArgumentError
  end

  it 'should not raise ArgumentError with 0 seconds' do
    expect {
      @iso8601duration.seconds = 0
    }.not_to raise_error
  end

  it 'should raise ArgumentError with -1 seconds' do
    expect {
      @iso8601duration.seconds = -1
    }.to raise_error ArgumentError
  end

  it 'should not raise ArgumentError with 0 fractional_second' do
    expect {
      @iso8601duration.fractional_second = 0
    }.not_to raise_error
  end

  it 'should raise ArgumentError with -1 fractional_second' do
    expect {
      @iso8601duration.fractional_second = -1
    }.to raise_error ArgumentError
  end

  it 'should raise ArgumentError with 1.0 fractional_second' do
    expect {
      @iso8601duration.fractional_second = 1.0
    }.to raise_error ArgumentError
  end
  
  it 'to_seconds should return 38898367.8' do
    @iso8601duration.to_seconds.should == 38898367.8
  end
  
  it 'should be comparable' do
    ISO8601Duration.new('P1Y2M3W4DT5H6M7.8S').should > ISO8601Duration.new('P1Y2M3W4DT5H6M7.7S')
  end
end
