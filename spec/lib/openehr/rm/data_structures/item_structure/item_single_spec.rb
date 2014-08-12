require File.dirname(__FILE__) + '/../../../../../spec_helper'

include OpenEHR::RM::DataStructures::ItemStructure
include OpenEHR::RM::DataStructures::ItemStructure::Representation
include OpenEHR::RM::DataTypes::Text

describe ItemSingle do
  before(:each) do
    element = double(Element, :archetype_node_id => 'at0002')
    item_single_name = DvText.new(:value => 'item single')
    @item_single = ItemSingle.new(:name => item_single_name,
                                  :archetype_node_id => 'at0001',
                                  :item => element)
  end

  it 'should be an instance of ItemSingle' do
    expect(@item_single).to be_an_instance_of ItemSingle
  end

  it 'should raise ArgumentError with nil item' do
    expect {
      @item_single.item = nil
    }.to raise_error ArgumentError
  end

  it 'should return as_hierarchy' do
    expect(@item_single.as_hierarchy.archetype_node_id).to eq('at0002')
  end
end
