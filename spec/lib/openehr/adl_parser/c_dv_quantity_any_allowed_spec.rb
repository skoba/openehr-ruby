# ticket 174
require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/parser_spec_helper'
require 'openehr/am/openehr_profile/data_types/quantity'
include ::OpenEHR::AM::OpenEHRProfile::DataTypes::Quantity
require 'openehr/rm/data_types/quantity'
include ::OpenEHR::RM::DataTypes::Quantity

describe 'CDvQuantity empty' do
  before(:all) do
    archetype = adl14_archetype('adl-test-entry.c_dv_quantity_empty.test.adl')
    @c_dv_quantity = archetype.definition.attributes[0].children[0].attributes[0].children[0].attributes[0].children[0]
  end

  it 'is an instance of CDvQuantity' do
    @c_dv_quantity.should be_an_instance_of CDvQuantity
  end

  it 'list is nil' do
    @c_dv_quantity.list.should be_nil
  end

  it 'property is nil' do
    @c_dv_quantity.property.should be_nil
  end

  it 'assumed value is nil' do
    @c_dv_quantity.assumed_value.should be_nil
  end

  it 'is any allowed' do
    @c_dv_quantity.should be_any_allowed
  end
end
