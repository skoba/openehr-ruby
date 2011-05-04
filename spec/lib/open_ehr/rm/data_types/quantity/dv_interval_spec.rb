require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::DataTypes::Quantity

describe DvInterval do
  before(:each) do
    @dv_interval = DvInterval.new(:upper => 100,
                                  :lower => 1)
  end

  it 'should be an instance of DvInterval' do
    @dv_interval.should be_an_instance_of DvInterval
  end

  it 's upper should be larger than lower' do
    @dv_interval.upper.should > @dv_interval.lower
  end
end
