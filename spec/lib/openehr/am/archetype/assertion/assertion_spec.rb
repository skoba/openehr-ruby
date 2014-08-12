require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::AM::Archetype::Assertion

describe Assertion do
  before(:each) do
    expression = double(ExprItem, :type => 'Boolean')
    $string_expression = "/[at0001]/speed[at0002]/kilometres/magnitude = " +
      "/[at0003]/speed[at0004]/miles/magnitude * 1.6"
    variables = double(Array, :size => 2)
    @assertion = OpenEHR::AM::Archetype::Assertion::Assertion.new(:tag => 'validity',
                               :expression => expression,
                               :string_expression => $string_expression,
                               :variables => variables)
  end

  it 'should be an instance of Assertion' do
    expect(@assertion).to be_an_instance_of OpenEHR::AM::Archetype::Assertion::Assertion
  end

  it 'expression should be assigned properly' do
    expect(@assertion.expression.type).to eq('Boolean')
  end

  it 'should raise ArgumentError when expression is nil' do
    expect {
      @assertion.expression = nil
    }.to raise_error ArgumentError
  end

  it 'should raise ArgumentError when expression type is not Boolean' do
    invalid_expression = double(ExprItem, :type => 'Real')
    expect {
      @assertion.expression = invalid_expression
    }.to raise_error ArgumentError
  end

  it 'tag should be assigned properly' do
    expect(@assertion.tag).to eq('validity')
  end

  it 'tag should not be empty' do
    expect {
      @assertion.tag = ''
    }.to raise_error ArgumentError
  end

  it 'should not raise ArgumentError when tag = nil' do
    expect {
      @assertion.tag = nil
    }.not_to raise_error
  end

  it 'string_expression should be assigned properly' do
    expect(@assertion.string_expression).to eq($string_expression)
  end

  it 'variables should be assigned properly' do
    expect(@assertion.variables.size).to be_equal 2
  end
end
