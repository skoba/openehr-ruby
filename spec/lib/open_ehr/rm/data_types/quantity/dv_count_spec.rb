require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::DataTypes::Quantity

describe DvCount do
  before(:each) do
    @dv_count = DvCount.new(:magnitude => 1)
  end

  it 'should be an instance of DvCount' do
    @dv_count.should be_an_instance_of DvCount
  end
end
