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
    expect(@item_tree.has_element_path?('/items[at0002]')).to be_truthy
  end

  it 'should return false with wrong node' do
    expect(@item_tree.has_element_path?('/items[at0005]')).to be_falsey
  end

  it 'path at002 should return two' do
    expect(@item_tree.element_at_path('/items[at0003]').name.value).to eq('two')
  end

  it 'path at005 should return nil' do
    expect(@item_tree.element_at_path('/items[at0005]')).to be_nil
  end

  it 'should returns ItemTree as Cluster' do
    expect(@item_tree.as_hierarchy.name.value).to eq('item tree')
  end

  describe 'real path support (element_at_path/has_element_path? delegate to item_at_path/path_exists?)' do
    it 'accepts a full path equivalent to the bare node id' do
      expect(@item_tree.element_at_path('/items[at0003]').name.value).to eq('two')
    end

    it 'has_element_path? accepts a full path too' do
      expect(@item_tree.has_element_path?('/items[at0002]')).to be_truthy
    end

    it 'resolves a path nested inside a Cluster (unlike the old top-level-only comparison)' do
      inner = Element.new(:name => DvText.new(:value => 'inner'), :archetype_node_id => 'at0010')
      cluster = Cluster.new(:name => DvText.new(:value => 'cluster'),
                            :archetype_node_id => 'at0009',
                            :items => [inner])
      nested_tree = ItemTree.new(:name => DvText.new(:value => 'nested tree'),
                                 :archetype_node_id => 'at0001',
                                 :items => [cluster])
      expect(nested_tree.element_at_path('/items[at0009]/items[at0010]')).to equal(inner)
    end

    it 'still warns but works for the legacy bare node id form' do
      expect { @item_tree.element_at_path('at0003') }.not_to raise_error
    end
  end
end
