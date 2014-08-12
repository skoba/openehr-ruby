require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::AM::Archetype::Assertion

describe ExprItem do
  before(:each) do
    @expr_item = ExprItem.new(:type => 'Real')
  end

  it 'should be an instance of ExprItem' do
    expect(@expr_item).to be_an_instance_of ExprItem
  end

  it 'type should be assigned properly' do
    expect(@expr_item.type).to eq('Real')
  end

  it 'should raise ArgumentError when type is nil' do
    expect {
      @expr_item.type = nil
    }.to raise_error ArgumentError
  end

  it 'should raise ArgumentError when type is empty' do
    expect {
      @expr_item.type = ''
    }.to raise_error ArgumentError
  end
end
