require File.dirname(__FILE__) + '/../../../spec_helper'
include OpenEHR::AssumedLibraryTypes

describe Interval do
  before(:each) do
    @interval = Interval.new(:upper => 10,
                             :lower => 1)
  end

  it 'should be an instance of Interval' do
    expect(@interval).to be_an_instance_of Interval
  end

  it 's upper should be greater than lower' do
    expect(@interval.upper).to be > @interval.lower
  end

  it 's upper should be equal 10' do
    expect(@interval.upper).to eq(10)
  end

  it 's lower should be equal 1' do
    expect(@interval.lower).to eq(1)
  end

  it 'should raise ArgumentError with smaller upper' do
    expect {@interval.upper = -1}.to raise_error ArgumentError
  end

  it 'should raise ArgumentError with greater lower' do
    expect {@interval.lower = 11}.to raise_error ArgumentError
  end

  it 'should have 5' do
    expect(@interval.has?(5)).to be_truthy
  end

  it 'should not have 11' do
    expect(@interval.has?(11)).not_to be_truthy
  end

  it 'should not have -1' do
    expect(@interval.has?(-1)).not_to be_truthy
  end

  it 'should have 10' do
    expect(@interval.has?(10)).to be_truthy
  end

  it 'should have 1' do
    expect(@interval.has?(1)).to be_truthy
  end

  it 'should be equal lower and upper is same' do
    interval = Interval.new(:upper => 10, :lower => 1)
    expect(@interval).to eq(interval)
  end

  describe Interval, 'when lower included' do
    before do
      @interval.lower_included = true
    end

    it 'should be lower_included' do
      expect(@interval).to be_lower_included
    end

    it 'should have 1 when lower included' do
      expect(@interval.has?(1)).to be_truthy
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
      expect(@interval).to be_upper_included
    end

    it 'should have 10 when upper included' do
      expect(@interval.has?(10)).to be_truthy
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
      expect(@interval).to be_upper_unbounded
    end

    it 'should have 11' do
      expect(@interval.has?(11)).to be_truthy
    end

    it 'should raise ArgumentError, when upper_included is assigned' do
      expect{
        @interval.upper_included = true
      }.to raise_error ArgumentError
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
      expect(@interval).to be_lower_unbounded
    end

    it 'should  have -10' do
      expect(@interval.has?(-10)).to be_truthy
    end

    it 'should raise ArgumentError, when lower_included is assigned' do
      expect{
        @interval.lower_included = true
      }.to raise_error ArgumentError
    end
  end

  it 'should raise ArgumentError both upper and lower is nil' do
    expect {
      Interval.new
    }.to raise_error ArgumentError
  end
end

