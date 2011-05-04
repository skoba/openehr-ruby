require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::DataTypes::Quantity

describe DvQuantified do
  before(:all) do
    @dv_quantified = DvQuantified.new(:magnitude => 1,
                                      :magnitude_status => '=')
  end

  it 'should be an instance of DvQuantified' do
    @dv_quantified.should be_an_instance_of DvQuantified
  end

  it 's magnitude should be 1' do
    @dv_quantified.magnitude.should be_equal 1
  end

  it 's magnitude_status should be =' do
    @dv_quantified.magnitude_status.should == '='
  end

  it 's comparable to other DvQuantified' do
    dv_quantified = DvQuantified.new(:magnitude => 2)
    @dv_quantified.should < dv_quantified
  end

  it 'should raise ArgumentError with invalid magnitude_status' do
    lambda {
      @dv_quantified.magnitude_status = '+'
    }.should raise_error ArgumentError
  end

  it 's accuracy should be unknown' do
    @dv_quantified.should be_accuracy_unknown
  end
end
