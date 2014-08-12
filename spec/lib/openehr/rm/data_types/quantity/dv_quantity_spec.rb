require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::DataTypes::Quantity

describe DvQuantity do
  before(:each) do
    @dv_quantity = DvQuantity.new(:magnitude => 3,
                                  :units => 'mg',
                                  :precision => 0)
  end

  it 'should be an instance of DvQuantity' do
    expect(@dv_quantity).to be_instance_of DvQuantity
  end

  it 's units should be mg' do
    expect(@dv_quantity.units).to eq('mg')
  end

  describe 'Mathematical Operation' do
    before(:each) do
      @dv_quantity5 = DvQuantity.new(:magnitude => 5,
                                     :units => 'mg')
    end
    
    it 'should be comparable to 5mg' do
      expect(@dv_quantity.is_strictly_comparable_to?(@dv_quantity5)).to be_truthy
    end

    it 'should be 8mg added 5mg' do
      dv_quantity = @dv_quantity + @dv_quantity5
      expect(dv_quantity.magnitude).to eq(8)
    end

    it 'should be -2mg minus 5mg' do
      dv_quantity = @dv_quantity - @dv_quantity5
      expect(dv_quantity.magnitude).to eq(-2)
    end

    it 's unit should be mg' do
      expect((@dv_quantity + @dv_quantity5).units).to eq('mg')
    end
  end

  it 'should not be comparable to 8km' do
    dv_quantity = DvQuantity.new(:magnitude => 8,
                                 :units => 'km')
    expect(@dv_quantity.is_strictly_comparable_to?(dv_quantity)).not_to be_truthy
  end

  it 'should return false with other type' do
    expect(@dv_quantity.is_strictly_comparable_to?(1)).not_to be_truthy
  end

  it 's precision should be equal 0' do
    expect(@dv_quantity.precision).to eq(0)
  end

  it 'should be integral' do
    expect(@dv_quantity.is_integral?).to be_truthy
  end

  it 'should not be integral do' do
    @dv_quantity.precision = 3
    expect(@dv_quantity.is_integral?).not_to be_truthy
  end

  it 'should not raise ArgumentError with -1 precision' do
    expect {
      @dv_quantity.precision = -1
    }.not_to raise_error 
  end

  it 'should raise ArgumentError with -2 precision' do
    expect {
      @dv_quantity.precision = -2
    }.to raise_error ArgumentError
  end
end
