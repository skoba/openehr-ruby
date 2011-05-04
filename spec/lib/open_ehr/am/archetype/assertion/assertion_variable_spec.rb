require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::AM::Archetype::Assertion

describe AssertionVariable do
  before(:each) do
    @assertion_variable =
      AssertionVariable.new(:name => 'test',
                            :definition => 'examine spec')
  end

  it 'name should be assigned properly' do
    @assertion_variable.name.should == 'test'
  end

  it 'should raise ArgumentError when name is nil' do
    lambda {
      @assertion_variable.name = nil
    }.should raise_error ArgumentError
  end

  it 'definition should be assigned properly' do
    @assertion_variable.definition.should == 'examine spec'
  end

  it 'should raise ArgumentError if definiton is nil' do
    lambda {
      @assertion_variable.definition = nil
    }.should raise_error ArgumentError
  end
end
