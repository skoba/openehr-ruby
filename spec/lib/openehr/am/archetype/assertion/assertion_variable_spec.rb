require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::AM::Archetype::Assertion

describe AssertionVariable do
  before(:each) do
    @assertion_variable =
      AssertionVariable.new(:name => 'test',
                            :definition => 'examine spec')
  end

  it 'name should be assigned properly' do
    expect(@assertion_variable.name).to eq('test')
  end

  it 'should raise ArgumentError when name is nil' do
    expect {
      @assertion_variable.name = nil
    }.to raise_error ArgumentError
  end

  it 'definition should be assigned properly' do
    expect(@assertion_variable.definition).to eq('examine spec')
  end

  it 'should raise ArgumentError if definiton is nil' do
    expect {
      @assertion_variable.definition = nil
    }.to raise_error ArgumentError
  end
end
