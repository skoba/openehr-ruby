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
    @item_tree.should be_an_instance_of ItemTree
  end

  it 'first item name should be one' do
    @item_tree.items[0].name.value.should == 'one'
  end

  it 'has valid element path' do
    @item_tree.has_element_path?('at0002').should be_true
  end

  it 'should return false with wrong node' do
    @item_tree.has_element_path?('at0005').should be_false
  end

  it 'path at002 should return two' do
    @item_tree.element_at_path('at0003').name.value.should == 'two'
  end

  it 'path at005 should return nil' do
    @item_tree.element_at_path('at0005').should be_nil
  end

  it 'should returns ItemTree as Cluster' do
    @item_tree.as_hierarchy.name.value.should == 'item tree'
  end
end
