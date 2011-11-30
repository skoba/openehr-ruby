require File.dirname(__FILE__) + '/../../../../../../spec_helper'
include OpenEHR::RM::DataTypes::Quantity::DateTime

describe DvDate do
  before(:each) do
    @dv_duration = DvDuration.new(:value => 'P1Y2M3W4DT5H6M7.7S')
  end

  it 'is an instance of DvDuration' do
    @dv_duration.should be_an_instance_of DvDuration
  end

  it 'year is 1' do
    @dv_duration.years.should be 1
  end

  it 'months is 2' do
    @dv_duration.months.should be 2
  end

  it 'weeks is 3' do
    @dv_duration.weeks.should be 3
  end

  it 'days is 4' do
    @dv_duration.days.should be 4
  end

  it 'hours should be 5' do
    @dv_duration.hours.should be 5
  end

  it 'minutes should be 6' do
    @dv_duration.minutes.should be 6
  end

  it 'seconds should be 7' do
    @dv_duration.seconds.should be 7
  end

  it 'fractional_second should be 0.7' do
    @dv_duration.fractional_second.should == 0.7
  end
end
