require File.dirname(__FILE__) + '/../../../../../../spec_helper'
include OpenEHR::RM::DataStructures::ItemStructure::Representation
include OpenEHR::RM::DataTypes::Text

describe Element do
  before(:each) do
    value = DvText.new(:value => 'test')
    @element = Element.new(:archetype_node_id => 'at0001',
                           :name => DvText.new(:value => 'element'),
                           :value => value)
  end

  it 'should be an instance of Element' do
    expect(@element).to be_an_instance_of Element
  end

  it 'value should be assigned as test' do
    expect(@element.value.value).to eq('test')
  end

  it 'nullflavor should be assigned'
end
