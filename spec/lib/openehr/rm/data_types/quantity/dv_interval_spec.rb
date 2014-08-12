require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::DataTypes::Quantity

describe DvInterval do
  before(:each) do
    @dv_interval = DvInterval.new(:upper => 100,
                                  :lower => 1)
  end

  it 'should be an instance of DvInterval' do
    expect(@dv_interval).to be_an_instance_of DvInterval
  end

  it 's upper should be larger than lower' do
    expect(@dv_interval.upper).to be > @dv_interval.lower
  end
end
