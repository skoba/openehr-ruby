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

    it 'should be 6mg when multiplied by 2' do
      dv_quantity = @dv_quantity * 2
      expect(dv_quantity.magnitude).to eq(6)
      expect(dv_quantity.units).to eq('mg')
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

  # RM 1.1.0 (SPECRM-65): units are UCUM by default, but may instead come
  # from another units system (identified by units_system), with
  # units_display_name available when the code alone isn't directly
  # displayable (e.g. UCUM 'Cel' vs display '°C').
  describe 'RM 1.1.0 units_system/units_display_name' do
    it 'defaults both to nil (UCUM assumed, no separate display form)' do
      expect(@dv_quantity.units_system).to be_nil
      expect(@dv_quantity.units_display_name).to be_nil
    end

    it 'accepts a units_system' do
      dv_quantity = DvQuantity.new(:magnitude => 37, :units => 'Cel', :units_system => 'http://hl7.org/fhir/ucum-units')
      expect(dv_quantity.units_system).to eq('http://hl7.org/fhir/ucum-units')
    end

    it 'accepts a units_display_name' do
      dv_quantity = DvQuantity.new(:magnitude => 37, :units => 'Cel', :units_display_name => '°C')
      expect(dv_quantity.units_display_name).to eq('°C')
    end

    it 'is strictly comparable to another quantity with the same units and units_system' do
      a = DvQuantity.new(:magnitude => 1, :units => 'Cel', :units_system => 'http://hl7.org/fhir/ucum-units')
      b = DvQuantity.new(:magnitude => 2, :units => 'Cel', :units_system => 'http://hl7.org/fhir/ucum-units')
      expect(a.is_strictly_comparable_to?(b)).to be_truthy
    end

    it 'is not strictly comparable to a quantity with the same units but a different units_system' do
      a = DvQuantity.new(:magnitude => 1, :units => 'Cel', :units_system => 'http://hl7.org/fhir/ucum-units')
      b = DvQuantity.new(:magnitude => 2, :units => 'Cel', :units_system => 'http://example.org/other-units')
      expect(a.is_strictly_comparable_to?(b)).to be_falsey
    end

    it 'is still strictly comparable to a same-units quantity when neither has a units_system (UCUM default)' do
      dv_quantity5 = DvQuantity.new(:magnitude => 5, :units => 'mg')
      expect(@dv_quantity.is_strictly_comparable_to?(dv_quantity5)).to be_truthy
    end
  end
end
