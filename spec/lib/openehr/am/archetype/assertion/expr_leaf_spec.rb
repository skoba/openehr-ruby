require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::AM::Archetype::Assertion

describe ExprLeaf do
  before(:each) do
    @expr_leaf = ExprLeaf.new(:type => 'Boolean',
                              :item => 'ANY',
                              :reference_type => 'DV_TEXT')
  end

  it 'should be an instance of ExprLeaf' do
    expect(@expr_leaf).to be_an_instance_of ExprLeaf
  end

  it 'item should be assigned properly' do
    expect(@expr_leaf.item).to eq('ANY')
  end

  it 'should raise ArgumentError when item is nil' do
    expect {
      @expr_leaf.item = nil
    }.to raise_error ArgumentError
  end

  it 'reference_type should be assigned properly' do
    expect(@expr_leaf.reference_type).to eq('DV_TEXT')
  end

  it 'should raise ArgumentError when reference_type is nil' do
    expect {
      @expr_leaf.reference_type = nil
    }.to raise_error ArgumentError
  end
end
