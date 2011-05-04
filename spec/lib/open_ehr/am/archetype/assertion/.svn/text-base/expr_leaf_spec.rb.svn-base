require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::AM::Archetype::Assertion

describe ExprLeaf do
  before(:each) do
    @expr_leaf = ExprLeaf.new(:type => 'Boolean',
                              :item => 'ANY',
                              :reference_type => 'DV_TEXT')
  end

  it 'should be an instance of ExprLeaf' do
    @expr_leaf.should be_an_instance_of ExprLeaf
  end

  it 'item should be assigned properly' do
    @expr_leaf.item.should == 'ANY'
  end

  it 'should raise ArgumentError when item is nil' do
    lambda {
      @expr_leaf.item = nil
    }.should raise_error ArgumentError
  end

  it 'reference_type should be assigned properly' do
    @expr_leaf.reference_type.should == 'DV_TEXT'
  end

  it 'should raise ArgumentError when reference_type is nil' do
    lambda {
      @expr_leaf.reference_type = nil
    }.should raise_error ArgumentError
  end
end
