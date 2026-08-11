require File.dirname(__FILE__) + '/../../../../../../spec_helper'
include OpenEHR::RM::DataStructures::ItemStructure::Representation
include OpenEHR::RM::DataTypes::Text

describe Cluster do
  before(:each) do
    item = double(Item)
    @cluster = Cluster.new(:archetype_node_id => 'at0001',
                           :name => DvText.new(:value => 'cluster'),
                           :items => [item, item])
  end

  it 'should be an isntance of Cluster' do
    expect(@cluster).to be_an_instance_of Cluster
  end

  it 'item size should be 2' do
    expect(@cluster.items.size).to eq(2)
  end

  it 'should raise ArgumentError with empty items' do
    expect {
      @cluster.items = []
    }.to raise_error ArgumentError
  end

  it 'auto-wires each item.parent to self' do
    element = Element.new(:archetype_node_id => 'at0002', :name => DvText.new(:value => 'element'))
    cluster = Cluster.new(:archetype_node_id => 'at0001',
                          :name => DvText.new(:value => 'cluster'),
                          :items => [element])
    expect(element.parent).to equal(cluster)
  end
end
