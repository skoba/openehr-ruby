require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::RM::DataStructures::ItemStructure
include OpenEHR::RM::DataStructures::ItemStructure::Representation
include OpenEHR::RM::DataTypes::Text

describe ItemList do
  before(:each) do
    items = %w{one two three}.collect do |n|
      Element.new(:name => DvText.new(:value => n),
                  :archetype_node_id => 'test')
    end
    item_list_name = DvText.new(:value => 'item list')
    @item_list = ItemList.new(:name => item_list_name,
                              :archetype_node_id => 'test',
                              :items => items)
    
  end

  it 'should be instance of ItemList' do
    @item_list.should be_an_instance_of ItemList
  end

  it 'count should be 3' do
    @item_list.item_count.should be_equal 3
  end

  it 'count should be 0' do
    @item_list.items = nil
    @item_list.item_count.should be_equal 0
  end


  it 'retrieve the names of all items' do
    @item_list.names.should == %w{one two three}.collect{|n|
      DvText.new(:value => n)}
  end

  it 'should return the item with a name' do
    @item_list.named_item('one').name.value.should == 'one'
  end

  it 'should return nil when item is not exist' do
    @item_list.named_item('four').should be_nil
  end

  it 'retrieve the ith item with number' do
    @item_list.ith_item(1).name.value.should == 'one'
  end

  it 'generate cluster of items' do
    @item_list.as_hierarchy.name.value.should == 'item list'
  end
end
