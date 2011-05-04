require File.dirname(__FILE__) + '/../../../spec_helper'
include OpenEHR::AssumedLibraryTypes

describe TimeDefinitions do
  describe 'year behavior' do
    it 'should more than zero in openEHR specification' do
      TimeDefinitions.should be_valid_year 0
    end

    it '-1 should not be valid year' do
      TimeDefinitions.should_not be_valid_year -1
    end

    it 'nil year should be invaild' do
      TimeDefinitions.should_not be_valid_year nil
    end
  end


  describe 'month behavior' do
    (1..12).each do |month|
      it "should valid #{month}" do
        TimeDefinitions.should be_valid_month month
      end
    end
    
    it '0th month should be invalid' do
      TimeDefinitions.should_not be_valid_month 0
    end
    
    it '13th month should be invalid' do
      TimeDefinitions.should_not be_valid_month 13
    end
  end

  describe 'day behavior' do
    it '0 day should not be valid day' do
      TimeDefinitions.should_not be_valid_day(1,2,0)
    end

    it '32 day should not be valid day' do
      TimeDefinitions.should_not be_valid_day(1,2,32)
    end

    it 'should be valid 2009-09-19' do
      TimeDefinitions.should be_valid_day(2009,9,19)
    end

    it 'should be invalid 2009 nil 19' do
      TimeDefinitions.should_not be_valid_day(2009, nil,19)
    end

    it 'should be invalid nil 09 19' do
      TimeDefinitions.should_not be_valid_day(nil, 9, 19)
    end

    it 'should be valid 2009 09' do
      TimeDefinitions.should be_valid_day(2009,9,nil)
    end
  end

  describe 'hour behavior' do
    it 'should be valid hour 0,0,0' do
      TimeDefinitions.should be_valid_hour(0,0,0)
    end

    it 'should be valid hour 12,59,59' do
      TimeDefinitions.should be_valid_hour(12,59,59)
    end

    it 'should not be valid hour 12,60,59' do
      TimeDefinitions.should_not be_valid_hour(12,60,59)
    end

    it 'should not be valid hour 12,59,60' do
      TimeDefinitions.should_not be_valid_hour(12,59,60)
    end

    it 'should be valid hour 24,0,0' do
      TimeDefinitions.should be_valid_hour(24,0,0)
    end

    it 'should not be valid hour 24,0,1' do
      TimeDefinitions.should_not be_valid_hour(24,0,1)
    end


    it 'should be vaild hour 12,1' do
      TimeDefinitions.should be_valid_hour(12,1)
    end

    it 'should not be valid hour 12,nil,1' do
      TimeDefinitions.should be_valid_hour(12,nil,1)
    end

    it 'should be valid hour 12' do
      TimeDefinitions.should be_valid_hour(12)
    end
  end

  describe 'minute limit' do
    it 'should be more than 0' do
      TimeDefinitions.should be_valid_minute 0
    end

    it 'should be not less than 0' do
      TimeDefinitions.should_not be_valid_minute -1
    end

    it 'should less than 60' do
      TimeDefinitions.should be_valid_minute 59
    end

    it 'should not valid minute 60' do
      TimeDefinitions.should_not be_valid_minute 60
    end
  end

  describe 'second limit' do
    it 'should be more than 0' do
      TimeDefinitions.should be_valid_second 0
    end

    it 'should be not less than 0' do
      TimeDefinitions.should_not be_valid_second -1
    end

    it 'should less than 60' do
      TimeDefinitions.should be_valid_second 59
    end

    it 'should not valid minute 60' do
      TimeDefinitions.should_not be_valid_second 60
    end
  end
end
