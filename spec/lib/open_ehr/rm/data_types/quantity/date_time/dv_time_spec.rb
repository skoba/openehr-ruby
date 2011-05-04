require File.dirname(__FILE__) + '/../../../../../../spec_helper'
include OpenEHR::RM::DataTypes::Quantity::DateTime

describe DvTime do
  before(:each) do
    @dv_time = DvTime.new(:value => '11:17:30.2')
  end

  it 'should be an instance of DvTime' do
    @dv_time.should be_an_instance_of DvTime
  end

  it 'hour should be 11' do
    @dv_time.hour.should == 11
  end

  it 'minute should be 17' do
    @dv_time.minute.should == 17
  end

  it 'second should be 30' do
    @dv_time.second.should == 30
  end

  it 'fractional_second should be 0.2' do
    @dv_time.fractional_second.should == 0.2
  end

  it 'magnitude should 40650.2' do
    @dv_time.magnitude.should == 40650.2
  end

  it 'should be ' do
    diff_time = DvTime.new(:value => '15:36:48.05')
    @dv_time.diff(diff_time).value.should =='P0Y0M0W0DT4H19M17.85S'
  end
end
