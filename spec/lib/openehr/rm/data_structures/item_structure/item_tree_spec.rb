require File.dirname(__FILE__) + '/../../../../../spec_helper'

include OpenEHR::RM::DataStructures::ItemStructure
include OpenEHR::RM::DataStructures::ItemStructure::Representation
include OpenEHR::RM::DataTypes::Text

describe ItemTree do
  before(:each) do
    i = 1
    items = %w{one two three}.collect do |name|
      i += 1
      Element.new(:name => DvText.new(:value => name),
                  :archetype_node_id => 'at000' + i.to_s)
    end
    name = DvText.new(:value => 'item tree')
    @item_tree = ItemTree.new(:name => name,
                              :archetype_node_id => 'at0001',
                              :items => items)
  end

  it 'should be an instance of ItemTree' do
    expect(@item_tree).to be_an_instance_of ItemTree
  end

  it 'first item name should be one' do
    expect(@item_tree.items[0].name.value).to eq('one')
  end

  it 'has valid element path' do
    expect(@item_tree.has_element_path?('at0002')).to be_truthy
  end

  it 'should return false with wrong node' do
    expect(@item_tree.has_element_path?('at0005')).to be_falsey
  end

  it 'path at002 should return two' do
    expect(@item_tree.element_at_path('at0003').name.value).to eq('two')
  end

  it 'path at005 should return nil' do
    expect(@item_tree.element_at_path('at0005')).to be_nil
  end

  it 'should returns ItemTree as Cluster' do
    expect(@item_tree.as_hierarchy.name.value).to eq('item tree')
  end
end
