require File.dirname(__FILE__) + '/../../../../../../spec_helper'
include OpenEHR::RM::DataStructures::ItemStructure::Representation
include OpenEHR::RM::DataTypes::Text

describe Cluster do
  before(:each) do
    item = stub(Item)
    @cluster = Cluster.new(:archetype_node_id => 'at0001',
                           :name => DvText.new(:value => 'cluster'),
                           :items => [item, item])
  end

  it 'should be an isntance of Cluster' do
    @cluster.should be_an_instance_of Cluster
  end

  it 'item size should be 2' do
    @cluster.items.size.should == 2
  end

  it 'should raise ArgumentError with empty items' do
    lambda {
      @cluster.items = []
    }.should raise_error ArgumentError
  end
end
