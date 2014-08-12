require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::DataTypes::Quantity

describe DvQuantified do
  before(:all) do
    @dv_quantified = DvQuantified.new(:magnitude => 1,
                                      :magnitude_status => '=')
  end

  it 'should be an instance of DvQuantified' do
    expect(@dv_quantified).to be_an_instance_of DvQuantified
  end

  it 's magnitude should be 1' do
    expect(@dv_quantified.magnitude).to be_equal 1
  end

  it 's magnitude_status should be =' do
    expect(@dv_quantified.magnitude_status).to eq('=')
  end

  it 's comparable to other DvQuantified' do
    dv_quantified = DvQuantified.new(:magnitude => 2)
    expect(@dv_quantified).to be < dv_quantified
  end

  it 'should raise ArgumentError with invalid magnitude_status' do
    expect {
      @dv_quantified.magnitude_status = '+'
    }.to raise_error ArgumentError
  end

  it 's accuracy should be unknown' do
    expect(@dv_quantified).to be_accuracy_unknown
  end
end
