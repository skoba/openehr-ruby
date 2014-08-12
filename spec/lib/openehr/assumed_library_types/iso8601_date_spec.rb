require File.dirname(__FILE__) + '/../../../spec_helper'
include OpenEHR::AssumedLibraryTypes

describe ISO8601Date do
  before do
    @iso8601date = ISO8601Date.new('2009-09-10')
  end

  it 'should be an instance of ISO8601Date' do
    expect(@iso8601date).to be_an_instance_of ISO8601Date
  end

  it 'year should be equal 2009' do
    expect(@iso8601date.year).to be_equal 2009
  end

  it 'month should be equal 9' do
    expect(@iso8601date.month).to be_equal 9
  end

  it 'day should be equal 10' do
    expect(@iso8601date.day).to be_equal 10
  end

  it 'should be 2009-09-10 as_string' do
    expect(@iso8601date.as_string).to eq('2009-09-10')
  end

  it 'should be extended ' do
    expect(@iso8601date.is_extended?).to be_truthy
  end

  it 'should parse vaild date form' do

  end

  it 'should parse valid adte form' do
    expect(ISO8601Date).to be_valid_iso8601_date '2009-09-22'
  end

  it 'should not parse invalid date form' do
    expect(ISO8601Date).not_to be_valid_iso8601_date '2009-13-54'
  end

  describe 'year behavior' do
    it 'should raise ArgumentError with nil year string' do
      expect {ISO8601Date.new('-09-02')}.to raise_error ArgumentError
    end

    it 'should raise ArgumentError with nil year' do
      expect {@iso8601date.year = nil}.to raise_error ArgumentError
    end

    it 'should not raise ArgumentError more than 0 year' do
      expect {@iso8601date.year = 0}.not_to raise_error
    end
  end

  describe 'month behavior' do
    it '1 month should not raise ArgumentError' do
      expect {@iso8601date.month = 1}.not_to raise_error
    end

    it '12 month should not raise ArgumentError' do
      expect {@iso8601date.month = 12}.not_to raise_error
    end

    it '13 month should raise ArgumentError' do
      expect {@iso8601date.month = 13}.to raise_error ArgumentError
    end

    it '0 month should raise ArgumentError' do
      expect {@iso8601date.month = 0}.to raise_error ArgumentError
    end
  end

  describe 'day behavior' do
    it '0 day should raise ArgumentError' do
      expect {@iso8601date.day = 0}.to raise_error ArgumentError
    end
  end

  [1,3,5,7,8,10,12].each do |m|
    describe '#{m}th month behavior' do
      before do
        @iso8601date.month = m
      end
      
      it 'should have 31 days' do
        expect {
          @iso8601date.day = 31
        }.not_to raise_error
      end

      it 'should not have 32 days' do
        expect {
          @iso8601date.day = 32
        }.to raise_error ArgumentError
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
        expect(@iso8601date).not_to be_leapyear 2009
      end

      it '2009-02-28 should not raise ArgumentError' do
        expect {@iso8601date.day = 28}.not_to raise_error
      end

      it '2009-02-29 should raise ArgumentError' do
        expect {@iso8601date.day = 29}.to raise_error ArgumentError
      end
    end

    describe '2008(leap year) behavior' do
      before do
        @iso8601date.year = 2008
      end

      it '2008 should be leap year' do
        expect(@iso8601date).to be_leapyear 2008
      end

      it '2008-02-29 should not raise ArgumentError' do
        expect {@iso8601date.day = 29}.not_to raise_error
      end

      it '2008-02-30 should raise ArgumentError' do
        expect {@iso8601date.day = 30}.to raise_error ArgumentError
      end
    end

    describe '2000(irregular leap year' do
      before do
        @iso8601date.year = 2000
      end

      it 'is leapyear' do
        expect(@iso8601date.leapyear? 2000).to be_truthy
      end

      it '2000-02-29 should not raise ArgumentError' do
        expect {@iso8601date.day = 29}.not_to raise_error
      end

      it '2000-02-30 should raise ArgumentError' do
        expect {@iso8601date.day = 30}.to raise_error ArgumentError
      end
    end
  end

  [4,6,9,11].each do |month|
    describe "#{month}th month behavior" do
      before do
        @iso8601date.month = month
      end

      it '30 day should not raise ArgumentError' do
        expect {
          @iso8601date.day = 30
        }.not_to raise_error
      end

      it '31 day should raise ArgumentError' do
        expect {
          @iso8601date.day = 31
        }.to raise_error ArgumentError
      end
    end
  end

  describe 'partial date data' do
    describe 'day unknown' do
      before do
        @iso8601date.day = nil
      end
      
      it 'day should be unknown' do
        expect(@iso8601date).to be_day_unknown
      end
      
      it 'should be 2009-09 as string' do
        expect(@iso8601date.as_string).to eq('2009-09')
      end
      
      it 'should be partial' do
        expect(@iso8601date.is_partial?).to be_truthy
      end
      
      it 'constructor pass partial date' do
        expect {
          ISO8601Date.new('2009-09')
        }.not_to raise_error
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
        expect {
          @iso8601date.day = 11
        }.to raise_error ArgumentError
      end

      it 's as_string should be 2009' do
        expect(@iso8601date.as_string).to eq('2009')
      end

      it 'constructor pass only year data' do
        expect {
          ISO8601Date.new('2009')
        }.not_to raise_error
      end
    end
  end

end
