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
    expect(@item_table).to be_an_instance_of ItemTable
  end

  it 's row count should be 2' do
    expect(@item_table.row_count).to be_equal 2
  end

  it 's row_count should be 0 when rows are nil' do
    @item_table.rows = nil
    expect(@item_table.row_count).to be_equal 0
  end

  it 's column_count should be 3' do
    expect(@item_table.column_count).to be_equal 3
  end

  it 'column_count should be 0 when @rows == nil' do
    @item_table.rows = nil
    expect(@item_table.column_count).to be_equal 0
  end

  it 's row_names should be cluster cluster' do
    expect(@item_table.row_names).to eq(%w{cluster cluster}.collect{|n|
      DvText.new(:value => n)})
  end

  it 's row_names should be empty when items are nil' do
    @item_table.rows = nil
    expect(@item_table.row_names).to eq([])
  end

  it 's column_names should one two three' do
    expect(@item_table.column_names).to eq(%w{one two three}.collect{|s|
      DvText.new(:value => s)})
  end

  it 's column_names should empty when items aer nil' do
    @item_table.rows = nil
    expect(@item_table.column_names).to eq([])
  end

  it 's ith_row(integer) should be ith row' do
    expect(@item_table.ith_row(2).items[1].name.value).to eq('five')
  end

  it 'should be invalid index under 0' do
    expect {@item_table.ith_row(0) }.to raise_error(ArgumentError)
  end

  it 'should be true because it has_row_with_name cluster' do
    expect(@item_table.has_row_with_name?('one')).to be_truthy
  end

  it 'should be true because it does not have_row_with_name key' do
    expect(@item_table.has_row_with_name?('two')).not_to be_truthy
  end

  it 'should raise argument error key is nil' do
    expect {@item_table.has_row_with_name?(nil)
      }.to raise_error(ArgumentError)
  end

  it 'should raise argument error key is empty' do
    expect {@item_table.has_row_with_name?('')
      }.to raise_error(ArgumentError)
  end

  it 'should be true because it has_column_with_name one' do
    expect(@item_table.has_column_with_name?('one')).to be_truthy
  end

  it 'should be false it has_column with name ten' do
    expect(@item_table.has_column_with_name?('ten')).to be_falsey
  end

  it 'second row should be named_row four' do
    @item_table.named_row('four').items[1].name.value = 'five'
  end

  it 'should be true if row has key' do
    expect(@item_table.has_row_with_key?(Set['one','two'])).to be_truthy
  end

  it 'should not be true if row has not key' do
    expect(@item_table.has_row_with_key?(Set['two','five'])).to be_falsey
  end

  it 'should be a first row that has one' do
    expect(@item_table.row_with_key(Set['one', 'two']).items[0].name.value).to eq('one')
  end

  it 'should raise argument error if row has no key' do
    expect {
      @item_table.row_with_key(Set['two','five'])}.to raise_error(ArgumentError)
  end

  it 'should be element at cell ij' do 
    expect(@item_table.element_at_cell_ij(2,2).name.value).to eq('five')
  end

  it 'should not be element at cell with wrong ij' do
    expect(@item_table.element_at_cell_ij(2,3).name.value).not_to eq('five')
  end

  it 'should be two element at named cell by row column' do
    @item_table.element_at_named_cell('cluster', 'three').name.value == 'three'
  end

  it 'should return nil when rows are nil' do
    @item_table.rows = nil
    expect(@item_table.row_count).to be_equal 0
  end

  it 'should be first row as hierachy' do
    expect(@item_table.as_hierarchy.name.value).to eq('cluster')
  end
end
