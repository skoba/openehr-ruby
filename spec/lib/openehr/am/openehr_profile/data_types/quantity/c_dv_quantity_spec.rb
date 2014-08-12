# ticket 199
require File.dirname(__FILE__) + '/../../../../../../spec_helper'
include ::OpenEHR::AM::OpenEHRProfile::DataTypes::Quantity
include ::OpenEHR::RM::DataTypes::Text
include OpenEHR::AssumedLibraryTypes

describe CDvQuantity do
  before(:each) do
    occurrences = Interval.new(:upper => 1, :lower => 1)
    property = double(CodePhrase, :code_string => 'AML')
    list = [CQuantityItem.new(:magnitude => 10, :units => 'mg')]
    @c_dv_quantity = CDvQuantity.new(:list => list,
                                     :path => 'value/quantity',
                                     :property => property,
                                     :occurrences => occurrences,
                                     :rm_type_name => 'DvQuantity')

  end

  it 'is an instance of CDvQuantity' do
    expect(@c_dv_quantity).to be_an_instance_of CDvQuantity
  end

  it 'path is value/quantity' do
    expect(@c_dv_quantity.path).to eq('value/quantity')
  end

  it 'property code string is AML' do
    expect(@c_dv_quantity.property.code_string).to eq('AML')
  end

  it 'first item of list is 10mg' do
    expect(@c_dv_quantity.list[0].magnitude).to be 10
  end

  it 'is not any allowed' do
    expect(@c_dv_quantity).not_to be_any_allowed
  end

  context 'list and property are not assigned' do
    before(:each) do
      @c_dv_quantity.list = nil
      @c_dv_quantity.property = nil
    end

    it 'is any allowed' do
      expect(@c_dv_quantity).to be_any_allowed
    end
  end
end
