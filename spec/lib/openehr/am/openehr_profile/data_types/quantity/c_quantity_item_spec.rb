# ticket 203
require File.dirname(__FILE__) + '/../../../../../../spec_helper'
require 'openehr/am/openehr_profile/data_types/quantity'
include OpenEHR::AssumedLibraryTypes
include OpenEHR::AM::OpenEHRProfile::DataTypes::Quantity

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
    expect {@c_quantity_item.units = nil}.to raise_error
  end

  it 'units is not be empty' do
    expect {@c_quantity_item.units = ''}.to raise_error
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
end
