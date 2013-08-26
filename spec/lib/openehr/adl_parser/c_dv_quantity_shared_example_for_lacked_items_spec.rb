# ticket 174
require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/parser_spec_helper'
require 'openehr/am/openehr_profile/data_types/quantity'
include ::OpenEHR::AM::OpenEHRProfile::DataTypes::Quantity
require 'openehr/rm/data_types/quantity'
include ::OpenEHR::RM::DataTypes::Quantity

shared_examples 'c_dv_quantity lacked items' do
  it 'parsed to archetypes' do
    archetype.should be_an_instance_of Archetype
  end
end

describe 'items only with property' do
  it_behaves_like 'c_dv_quantity lacked items' do
    let(:archetype) {adl14_archetype('adl-test-entry.c_dv_quantity_property.test.adl')}
  end
end

describe 'items only with list' do
  it_behaves_like 'c_dv_quantity lacked items' do
    let(:archetype) {adl14_archetype('adl-test-entry.c_dv_quantity_list.test.adl')}
  end
end

describe 'reversed items' do
  it_behaves_like 'c_dv_quantity lacked items' do
    let(:archetype) {adl14_archetype('adl-test-entry.c_dv_quantity_reversed.test.adl')}
  end
end
describe 'units only' do
  it_behaves_like 'c_dv_quantity lacked items' do
    let(:archetype) {adl14_archetype('adl-test-entry.c_dv_quantity_item_units_only.test.adl')}
  end
end
