require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::DataTypes::Quantity

describe DvQuantity do
  before(:each) do
    @dv_quantity = DvQuantity.new(:magnitude => 3,
                                  :units => 'mg',
                                  :precision => 0)
  end

  it 'should be an instance of DvQuantity' do
    @dv_quantity.should be_instance_of DvQuantity
  end

  it 's units should be mg' do
    @dv_quantity.units.should == 'mg'
  end

  describe 'Mathematical Operation' do
    before(:each) do
      @dv_quantity5 = DvQuantity.new(:magnitude => 5,
                                     :units => 'mg')
    end
    
    it 'should be comparable to 5mg' do
      @dv_quantity.is_strictly_comparable_to?(@dv_quantity5).should be_true
    end

    it 'should be 8mg added 5mg' do
      dv_quantity = @dv_quantity + @dv_quantity5
      dv_quantity.magnitude.should == 8
    end

    it 'should be -2mg minus 5mg' do
      dv_quantity = @dv_quantity - @dv_quantity5
      dv_quantity.magnitude.should == -2
    end

    it 's unit should be mg' do
      (@dv_quantity + @dv_quantity5).units.should == 'mg'
    end
  end

  it 'should not be comparable to 8km' do
    dv_quantity = DvQuantity.new(:magnitude => 8,
                                 :units => 'km')
    @dv_quantity.is_strictly_comparable_to?(dv_quantity).should_not be_true
  end

  it 'should return false with other type' do
    @dv_quantity.is_strictly_comparable_to?(1).should_not be_true
  end

  it 's precision should be equal 0' do
    @dv_quantity.precision.should == 0
  end

  it 'should be integral' do
    @dv_quantity.is_integral?.should be_true
  end

  it 'should not be integral do' do
    @dv_quantity.precision = 3
    @dv_quantity.is_integral?.should_not be_true
  end

  it 'should not raise ArgumentError with -1 precision' do
    lambda {
      @dv_quantity.precision = -1
    }.should_not raise_error ArgumentError
  end

  it 'should raise ArgumentError with -2 precision' do
    lambda {
      @dv_quantity.precision = -2
    }.should raise_error ArgumentError
  end
end
