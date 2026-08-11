require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::DataTypes::Quantity

describe DvCount do
  before(:each) do
    @dv_count = DvCount.new(:magnitude => 1)
  end

  it 'should be an instance of DvCount' do
    expect(@dv_count).to be_an_instance_of DvCount
  end

  it 'magnitude should be 1' do
    expect(@dv_count.magnitude).to eq(1)
  end

  it 'should raise ArgumentError for a non-Integer magnitude' do
    expect {
      DvCount.new(:magnitude => 1.5)
    }.to raise_error ArgumentError
  end

  it 'should accept a re-assigned Integer magnitude' do
    @dv_count.magnitude = 2
    expect(@dv_count.magnitude).to eq(2)
  end
end
