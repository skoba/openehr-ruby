require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::DataTypes::Quantity

describe DvAbsoluteQuantity do
  before(:each) do
    @dv_absolute_quantity = DvAbsoluteQuantity.new(:magnitude => 7)
  end

  it 'should be an instance of DvAbsoluteQuantity' do
    @dv_absolute_quantity.should be_an_instance_of DvAbsoluteQuantity
  end

  it 's add 3 method should magnitude 10' do
    dv_absolute_quantity10 =
      @dv_absolute_quantity.add(DvAbsoluteQuantity.new(:magnitude => 3))
    dv_absolute_quantity10.magnitude.should == 10
  end

  it 's diff method should return DvAmount' do    
    diff_dv_amount = @dv_absolute_quantity.diff(DvAbsoluteQuantity.new(
                                                    :magnitude => 10))
    diff_dv_amount.magnitude.should == 3
  end

  it 's subtract method should raise NotImplementedError' do
    sub_dv_absolute_quantity = @dv_absolute_quantity.subtract(DvAbsoluteQuantity.new(:magnitude => 10))
    sub_dv_absolute_quantity.magnitude.should == -3
  end

  it 'should be raise ArgumentError when type mismatched' do
    lambda {
      @dv_absolute_quantity.add(1)
    }.should raise_error ArgumentError
  end
end
