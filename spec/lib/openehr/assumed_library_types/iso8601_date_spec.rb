require File.dirname(__FILE__) + '/../../../spec_helper'
include OpenEHR::AssumedLibraryTypes

describe ISO8601Date do
  before do
    @iso8601date = ISO8601Date.new('2009-09-10')
  end

  it 'should be an instance of ISO8601Date' do
    @iso8601date.should be_an_instance_of ISO8601Date
  end

  it 'year should be equal 2009' do
    @iso8601date.year.should be_equal 2009
  end

  it 'month should be equal 9' do
    @iso8601date.month.should be_equal 9
  end

  it 'day should be equal 10' do
    @iso8601date.day.should be_equal 10
  end

  it 'should be 2009-09-10 as_string' do
    @iso8601date.as_string.should == '2009-09-10'
  end

  it 'should be extended ' do
    @iso8601date.is_extended?.should be_true
  end

  it 'should parse vaild date form' do

  end

  it 'should parse valid adte form' do
    ISO8601Date.should be_valid_iso8601_date '2009-09-22'
  end

  it 'should not parse invalid date form' do
    ISO8601Date.should_not be_valid_iso8601_date '2009-13-54'
  end

  describe 'year behavior' do
    it 'should raise ArgumentError with nil year string' do
      lambda{ISO8601Date.new('-09-02')}.should raise_error ArgumentError
    end

    it 'should raise ArgumentError with nil year' do
      lambda{@iso8601date.year = nil}.should raise_error ArgumentError
    end

    it 'should not raise ArgumentError more than 0 year' do
      lambda{@iso8601date.year = 0}.should_not raise_error ArgumentError
    end
  end

  describe 'month behavior' do
    it '1 month should not raise ArgumentError' do
      lambda{@iso8601date.month = 1}.should_not raise_error ArgumentError
    end

    it '12 month should not raise ArgumentError' do
      lambda{@iso8601date.month = 12}.should_not raise_error ArgumentError
    end

    it '13 month should raise ArgumentError' do
      lambda{@iso8601date.month = 13}.should raise_error ArgumentError
    end

    it '0 month should raise ArgumentError' do
      lambda{@iso8601date.month = 0}.should raise_error ArgumentError
    end
  end

  describe 'day behavior' do
    it '0 day should raise ArgumentError' do
      lambda{@iso8601date.day = 0}.should raise_error ArgumentError
    end
  end

  [1,3,5,7,8,10,12].each do |m|
    describe '#{m}th month behavior' do
      before do
        @iso8601date.month = m
      end
      
      it 'should have 31 days' do
        lambda{
          @iso8601date.day = 31
        }.should_not raise_error ArgumentError
      end

      it 'should not have 32 days' do
        lambda{
          @iso8601date.day = 32
        }.should raise_error ArgumentError
      end
    end
  end

  describe 'February and leap year behavior' do
    before do
      @iso8601date.month = 2
    end

    describe '2009(not leap year) behavior' do
      before do
        @iso8601date.year = 2009
      end

      it '2009 should not be leap year' do
        @iso8601date.should_not be_leapyear 2009
      end

      it '2009-02-28 should not raise ArgumentError' do
        lambda{@iso8601date.day = 28}.should_not raise_error ArgumentError
      end

      it '2009-02-29 should raise ArgumentError' do
        lambda{@iso8601date.day = 29}.should raise_error ArgumentError
      end
    end

    describe '2008(leap year) behavior' do
      before do
        @iso8601date.year = 2008
      end

      it '2008 should be leap year' do
        @iso8601date.should be_leapyear 2008
      end

      it '2008-02-29 should not raise ArgumentError' do
        lambda{@iso8601date.day = 29}.should_not raise_error ArgumentError
      end

      it '2008-02-30 should raise ArgumentError' do
        lambda{@iso8601date.day = 30}.should raise_error ArgumentError
      end
    end

    describe '2000(irregular leap year' do
      before do
        @iso8601date.year = 2000
      end

      it 'should not leapyear' do
        @iso8601date.should be_leapyear 2000
      end

      it '2000-02-29 should not raise ArgumentError' do
        lambda{@iso8601date.day = 29}.should_not raise_error ArgumentError
      end

      it '2000-02-30 should raise ArgumentError' do
        lambda{@iso8601date.day = 30}.should raise_error ArgumentError
      end
    end
  end

  [4,6,9,11].each do |month|
    describe "#{month}th month behavior" do
      before do
        @iso8601date.month = month
      end

      it '30 day should not raise ArgumentError' do
        lambda{
          @iso8601date.day = 30
        }.should_not raise_error ArgumentError
      end

      it '31 day should raise ArgumentError' do
        lambda{
          @iso8601date.day = 31
        }.should raise_error ArgumentError
      end
    end
  end

  describe 'partial date data' do
    describe 'day unknown' do
      before do
        @iso8601date.day = nil
      end
      
      it 'day should be unknown' do
        @iso8601date.should be_day_unknown
      end
      
      it 'should be 2009-09 as string' do
        @iso8601date.as_string.should == '2009-09'
      end
      
      it 'should be partial' do
        @iso8601date.is_partial?.should be_true
      end
      
      it 'constructor pass partial date' do
        lambda {
          ISO8601Date.new('2009-09')
        }.should_not raise_error ArgumentError
      end

      after do
        @iso8601date.day = 10
      end
    end
    
    describe 'month unknown' do
      before do
        @iso8601date.day = nil
        @iso8601date.month = nil
      end
      
      it 'should raise ArgumentError with nil month and not nil day' do
        lambda {
          @iso8601date.day = 11
        }.should raise_error ArgumentError
      end

      it 's as_string should be 2009' do
        @iso8601date.as_string.should == '2009'
      end

      it 'constructor pass only year data' do
        lambda {
          ISO8601Date.new('2009')
        }.should_not raise_error ArgumentError
      end
    end
  end

end
