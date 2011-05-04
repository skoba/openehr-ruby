require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::AM::Archetype::Assertion

describe ExprItem do
  before(:each) do
    @expr_item = ExprItem.new(:type => 'Real')
  end

  it 'should be an instance of ExprItem' do
    @expr_item.should be_an_instance_of ExprItem
  end

  it 'type should be assigned properly' do
    @expr_item.type.should == 'Real'
  end

  it 'should raise ArgumentError when type is nil' do
    lambda {
      @expr_item.type = nil
    }.should raise_error ArgumentError
  end

  it 'should raise ArgumentError when type is empty' do
    lambda {
      @expr_item.type = ''
    }.should raise_error ArgumentError
  end
end
