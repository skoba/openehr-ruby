require File.dirname(__FILE__) + '/../../../../../spec_helper'

include OpenEHR::RM::DataStructures::ItemStructure
include OpenEHR::RM::DataStructures::ItemStructure::Representation
include OpenEHR::RM::DataTypes::Text

def row(args)
  return args.collect do |n|
    Element.new(:name => DvText.new(:value => n),
                :archetype_node_id => 'test')
  end
end

def cluster_builder(name,rows)
  return Cluster.new(:name => DvText.new(:value => name),
                     :archetype_node_id => 'test',
                     :items => rows)
end

describe ItemTable do
  before(:each) do
    row1 = row(%w{one two three})
    row2 = row(%w{four five six})
    rows = [row1, row2].collect{|r| cluster_builder('cluster',r)}
    @item_table = ItemTable.new(:name => DvText.new(:value => 'item table'),
                                :archetype_node_id => 'test',
                                :rows => rows)
  end

  it 'should be an instance of ItemTable' do
    @item_table.should be_an_instance_of ItemTable
  end

  it 's row count should be 2' do
    @item_table.row_count.should be_equal 2
  end

  it 's row_count should be 0 when rows are nil' do
    @item_table.rows = nil
    @item_table.row_count.should be_equal 0
  end

  it 's column_count should be 3' do
    @item_table.column_count.should be_equal 3
  end

  it 'column_count should be 0 when @rows == nil' do
    @item_table.rows = nil
    @item_table.column_count.should be_equal 0
  end

  it 's row_names should be cluster cluster' do
    @item_table.row_names.should == %w{cluster cluster}.collect{|n|
      DvText.new(:value => n)}
  end

  it 's row_names should be empty when items are nil' do
    @item_table.rows = nil
    @item_table.row_names.should == []
  end

  it 's column_names should one two three' do
    @item_table.column_names.should == %w{one two three}.collect{|s|
      DvText.new(:value => s)}
  end

  it 's column_names should empty when items aer nil' do
    @item_table.rows = nil
    @item_table.column_names.should == []
  end

  it 's ith_row(integer) should be ith row' do
    @item_table.ith_row(2).items[1].name.value.should == 'five'
  end

  it 'should be invalid index under 0' do
    lambda {@item_table.ith_row(0) }.should raise_error(ArgumentError)
  end

  it 'should be true because it has_row_with_name cluster' do
    @item_table.has_row_with_name?('one').should be_true
  end

  it 'should be true because it does not have_row_with_name key' do
    @item_table.has_row_with_name?('two').should_not be_true
  end

  it 'should raise argument error key is nil' do
    lambda {@item_table.has_row_with_name?(nil)
      }.should raise_error(ArgumentError)
  end

  it 'should raise argument error key is empty' do
    lambda {@item_table.has_row_with_name?('')
      }.should raise_error(ArgumentError)
  end

  it 'should be true because it has_column_with_name one' do
    @item_table.has_column_with_name?('one').should be_true
  end

  it 'should be false it has_column with name ten' do
    @item_table.has_column_with_name?('ten').should be_false
  end

  it 'second row should be named_row four' do
    @item_table.named_row('four').items[1].name.value = 'five'
  end

  it 'should be true if row has key' do
    @item_table.has_row_with_key?(Set['one','two']).should be_true
  end

  it 'should not be true if row has not key' do
    @item_table.has_row_with_key?(Set['two','five']).should be_false
  end

  it 'should be a first row that has one' do
    @item_table.row_with_key(Set['one', 'two']).items[0].name.value.should =='one'
  end

  it 'should raise argument error if row has no key' do
    lambda {
      @item_table.row_with_key(Set['two','five'])}.should raise_error(ArgumentError)
  end

  it 'should be element at cell ij' do 
    @item_table.element_at_cell_ij(2,2).name.value.should == 'five'
  end

  it 'should not be element at cell with wrong ij' do
    @item_table.element_at_cell_ij(2,3).name.value.should_not == 'five'
  end

  it 'should be two element at named cell by row column' do
    @item_table.element_at_named_cell('cluster', 'three').name.value == 'three'
  end

  it 'should return nil when rows are nil' do
    @item_table.rows = nil
    @item_table.row_count.should be_equal 0
  end

  it 'should be first row as hierachy' do
    @item_table.as_hierarchy.name.value.should == 'cluster'
  end
end
