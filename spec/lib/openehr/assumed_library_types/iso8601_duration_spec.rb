require File.dirname(__FILE__) + '/../../../spec_helper'
include OpenEHR::AssumedLibraryTypes

describe ISO8601Duration do
  before(:each) do
    @iso8601duration = ISO8601Duration.new('P1Y2M3W4DT5H6M7.8S')
  end

  it 'should be an instance of ISO8601Duration' do
    expect(@iso8601duration).to be_an_instance_of ISO8601Duration
  end

  it 'years should be 1' do
    expect(@iso8601duration.years).to be_equal 1
  end

  it 'months should be 2' do
    expect(@iso8601duration.months).to be_equal 2
  end

  it 'weeks should be 3' do
    expect(@iso8601duration.weeks).to be_equal 3
  end

  it 'days should be 4' do
    expect(@iso8601duration.days).to be_equal 4
  end

  it 'hours should be 5' do
    expect(@iso8601duration.hours).to be_equal 5
  end

  it 'minutes should be 6' do
    expect(@iso8601duration.minutes).to be_equal 6
  end

  it 'seconds should be 7' do
    expect(@iso8601duration.seconds).to be_equal 7
  end

  it 'fractional_seconds should be .8' do
    expect(@iso8601duration.fractional_second).to eq(0.8)
  end

  it 'should be equal P1Y2M3W4DT5H6M7.8S as string' do
    expect(@iso8601duration.as_string).to eq('P1Y2M3W4DT5H6M7.8S')
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
    expect(@iso8601duration.to_seconds).to eq(38898367.8)
  end
  
  it 'should be comparable' do
    expect(ISO8601Duration.new('P1Y2M3W4DT5H6M7.8S')).to be > ISO8601Duration.new('P1Y2M3W4DT5H6M7.7S')
  end

  describe 'multi-digit and partial components' do
    it 'should parse P10D with days 10' do
      expect(ISO8601Duration.new('P10D').days).to eq(10)
    end

    it 'should leave absent components nil, not zero' do
      duration = ISO8601Duration.new('P1Y')
      expect(duration.months).to be_nil
      expect(duration.weeks).to be_nil
      expect(duration.days).to be_nil
      expect(duration.hours).to be_nil
    end

    it 'should round-trip P1Y as P1Y' do
      expect(ISO8601Duration.new('P1Y').as_string).to eq('P1Y')
    end

    it 'should raise ArgumentError for a malformed duration string' do
      expect {
        ISO8601Duration.new('not-a-duration')
      }.to raise_error ArgumentError
    end
  end

  # RM 1.1.0 (SPECRM-96): "consistently support negative durations" - a
  # leading '-' before 'P' means "prior to [an unstated origin point]",
  # e.g. adjusted age for a premature newborn. Component setters
  # (years=, days=, ...) still reject negative magnitudes - the sign
  # applies to the duration as a whole, not each component - so it's
  # tracked separately.
  describe 'negative durations' do
    it 'parses a negative duration without raising' do
      expect { ISO8601Duration.new('-P10D') }.not_to raise_error
    end

    it 'is negative? true for a negative duration' do
      expect(ISO8601Duration.new('-P10D')).to be_negative
    end

    it 'is negative? false for a positive duration' do
      expect(ISO8601Duration.new('P10D')).not_to be_negative
    end

    it 'keeps component magnitudes non-negative even when the duration is negative' do
      duration = ISO8601Duration.new('-P10D')
      expect(duration.days).to eq(10)
    end

    it 'negates to_seconds' do
      expect(ISO8601Duration.new('-P1D').to_seconds).to eq(-86400.0)
    end

    it 'round-trips as_string with the leading minus' do
      expect(ISO8601Duration.new('-P3M').as_string).to eq('-P3M')
    end

    it 'a negative duration compares as less than the same positive duration' do
      expect(ISO8601Duration.new('-P1D')).to be < ISO8601Duration.new('P1D')
    end
  end
end
