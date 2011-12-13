require File.dirname(__FILE__) + '/../../../spec_helper'
include OpenEHR::AssumedLibraryTypes

describe Interval do
  before(:each) do
    @interval = Interval.new(:upper => 10,
                             :lower => 1)
  end

  it 'should be an instance of Interval' do
    @interval.should be_an_instance_of Interval
  end

  it 's upper should be greater than lower' do
    @interval.upper.should be > @interval.lower
  end

  it 's upper should be equal 10' do
    @interval.upper.should == 10
  end

  it 's lower should be equal 1' do
    @interval.lower.should == 1
  end

  it 'should raise ArgumentError with smaller upper' do
    lambda {@interval.upper = -1}.should raise_error ArgumentError
  end

  it 'should raise ArgumentError with greater lower' do
    lambda {@interval.lower = 11}.should raise_error ArgumentError
  end

  it 'should have 5' do
    @interval.has?(5).should be_true
  end

  it 'should not have 11' do
    @interval.has?(11).should_not be_true
  end

  it 'should not have -1' do
    @interval.has?(-1).should_not be_true
  end

  it 'should not have 10' do
    @interval.has?(10).should_not be_true
  end

  it 'should not have 1' do
    @interval.has?(1).should_not be_true
  end

  it 'should be equal lower and upper is same' do
    interval = Interval.new(:upper => 10, :lower => 1)
    @interval.should == interval
  end

  describe Interval, 'when lower included' do
    before do
      @interval.lower_included = true
    end

    it 'should be lower_included' do
      @interval.should be_lower_included
    end

    it 'should have 1 when lower included' do
      @interval.has?(1).should be_true
    end

    after do
      @interval.lower_included = false
    end
  end

  describe Interval, 'when upper included' do
    before do
      @interval.upper_included = true
    end

    it 'should be upper uncluded' do
      @interval.should be_upper_included
    end

    it 'should have 10 when upper included' do
      @interval.has?(10).should be_true
    end

    after do
      @interval.upper_included = false
    end
  end

  describe Interval, 'when upper unbounded' do
    before do
      @interval.upper = nil
    end

    it 'should be upper unbounded' do
      @interval.should be_upper_unbounded
    end

    it 'should have 11' do
      @interval.has?(11).should be_true
    end

    it 'should raise ArgumentError, when upper_included is assigned' do
      lambda{
        @interval.upper_included = true
      }.should raise_error ArgumentError
    end

    after do
      @interval.upper = 10
    end
  end

  describe Interval, 'when lower unbounded' do
    before do
      @interval.lower = nil
    end

    it 'should be lower unbounded' do
      @interval.should be_lower_unbounded
    end

    it 'should  have -10' do
      @interval.has?(-10).should be_true
    end

    it 'should raise ArgumentError, when lower_included is assigned' do
      lambda{
        @interval.lower_included = true
      }.should raise_error ArgumentError
    end
  end

  it 'should raise ArgumentError both upper and lower is nil' do
    lambda {
      Interval.new
    }.should raise_error ArgumentError
  end
end

