require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::AM::Archetype::ConstraintModel
include OpenEHR::AssumedLibraryTypes

describe Cardinality do
  before(:each) do
    interval = Interval.new(:upper => 1, :lower => 0)
    @cardinality = Cardinality.new(:is_ordered => true,
                                   :is_unique => true,
                                   :interval => interval)
  end

  it 'should be an instance of Cardinality' do
    expect(@cardinality).to be_an_instance_of Cardinality
  end

  it 'is_ordered should be assigned properly' do
    expect(@cardinality).to be_ordered
  end

  it 'is_ordered should be false' do
    @cardinality.is_ordered = false
    expect(@cardinality).not_to be_ordered
  end

  it 'is_unique should be assigned properly' do
    expect(@cardinality).to be_unique
  end

  it 'is_unique should not be true' do
    @cardinality.is_unique = false
    expect(@cardinality).not_to be_unique
  end

  it 'interval should be assigned properly' do
    expect(@cardinality.interval.upper).to be_equal 1
  end

  it 'is_set represent not ordered and unique' do
    expect(@cardinality).not_to be_set
  end

  it 'is_set should be true' do
    @cardinality.is_unique = true
    @cardinality.is_ordered = false
    expect(@cardinality).to be_set
  end

  it 'is_list represent ordered and not unique' do
    @cardinality.is_ordered = true
    @cardinality.is_unique = false
    expect(@cardinality).to be_list
  end

  it 'is_list should not be true' do
    expect(@cardinality).not_to be_list
  end

  it 'is_bag represent not ordered and not unique' do
    @cardinality.is_ordered = false
    @cardinality.is_unique = false
    expect(@cardinality).to be_bag
  end

  it 'is_bag? should not be true' do
    expect(@cardinality).not_to be_bag
  end
end
