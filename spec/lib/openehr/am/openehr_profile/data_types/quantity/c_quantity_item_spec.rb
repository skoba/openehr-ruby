# ticket 203
require File.dirname(__FILE__) + '/../../../../../../spec_helper'
require 'openehr/am/openehr_profile/data_types/quantity'
include OpenEHR::AssumedLibraryTypes
include OpenEHR::AM::OpenEHRProfile::DataTypes::Quantity
include OpenEHR::RM::DataTypes::Quantity

describe CQuantityItem do
  before(:each) do
    magnitude = Interval.new(:upper => 100, :lower => 0)
    precision = Interval.new(:upper => 10, :lower => 2)
    @c_quantity_item = CQuantityItem.new(:units => 'mg',
                                         :magnitude => magnitude,
                                         :precision => precision)
  end

  it 'is an instance of CQuantityItem' do
    expect(@c_quantity_item).to be_an_instance_of CQuantityItem
  end

  it 'magnitude upper is 100' do
    expect(@c_quantity_item.magnitude.upper).to be 100
  end

  it 'precision lower is -2' do
    expect(@c_quantity_item.precision.lower).to be 2
  end

  it 'units is not nil' do
    expect {@c_quantity_item.units = nil}.to raise_error ArgumentError
  end

  it 'units is not be empty' do
    expect {@c_quantity_item.units = ''}.to raise_error ArgumentError
  end

  it 'is not precision unconstrained' do
    expect(@c_quantity_item).not_to be_precision_unconstrained
  end
  context 'precision unconstrained' do
    before(:each) do
      @c_quantity_item.precision = Interval.new(:upper => -1, :lower => -1)
    end

    it 'precision unconstrained is true' do
      expect(@c_quantity_item).to be_precision_unconstrained
    end
  end

  context 'precision is absent' do
    before(:each) do
      @c_quantity_item.precision = nil
    end

    it 'precision unconstrained is true, not a NoMethodError' do
      expect(@c_quantity_item).to be_precision_unconstrained
    end
  end

  describe '#matches?' do
    it 'is true when units, magnitude and precision are all within range' do
      value = DvQuantity.new(:magnitude => 50, :units => 'mg', :precision => 5)
      expect(@c_quantity_item.matches?(value)).to be true
    end

    it 'is false when units differ' do
      value = DvQuantity.new(:magnitude => 50, :units => 'kg', :precision => 5)
      expect(@c_quantity_item.matches?(value)).to be false
    end

    it 'is false when magnitude is outside range' do
      value = DvQuantity.new(:magnitude => 200, :units => 'mg', :precision => 5)
      expect(@c_quantity_item.matches?(value)).to be false
    end

    it 'is false when precision is outside range' do
      value = DvQuantity.new(:magnitude => 50, :units => 'mg', :precision => 20)
      expect(@c_quantity_item.matches?(value)).to be false
    end

    it 'ignores precision when unconstrained' do
      @c_quantity_item.precision = Interval.new(:upper => -1, :lower => -1)
      value = DvQuantity.new(:magnitude => 50, :units => 'mg', :precision => 20)
      expect(@c_quantity_item.matches?(value)).to be true
    end

    it 'ignores magnitude when unconstrained' do
      @c_quantity_item.magnitude = nil
      value = DvQuantity.new(:magnitude => 999, :units => 'mg', :precision => 5)
      expect(@c_quantity_item.matches?(value)).to be true
    end
  end
end
