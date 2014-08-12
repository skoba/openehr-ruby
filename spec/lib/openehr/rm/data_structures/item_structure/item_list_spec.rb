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
    expect(@item_list).to be_an_instance_of ItemList
  end

  it 'count should be 3' do
    expect(@item_list.item_count).to be_equal 3
  end

  it 'count should be 0' do
    @item_list.items = nil
    expect(@item_list.item_count).to be_equal 0
  end


  it 'retrieve the names of all items' do
    expect(@item_list.names).to eq(%w{one two three}.collect{|n|
      DvText.new(:value => n)})
  end

  it 'should return the item with a name' do
    expect(@item_list.named_item('one').name.value).to eq('one')
  end

  it 'should return nil when item is not exist' do
    expect(@item_list.named_item('four')).to be_nil
  end

  it 'retrieve the ith item with number' do
    expect(@item_list.ith_item(1).name.value).to eq('one')
  end

  it 'generate cluster of items' do
    expect(@item_list.as_hierarchy.name.value).to eq('item list')
  end
end
