require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::AM::Archetype::Assertion

describe Assertion do
  before(:each) do
    expression = stub(ExprItem, :type => 'Boolean')
    $string_expression = "/[at0001]/speed[at0002]/kilometres/magnitude = " +
      "/[at0003]/speed[at0004]/miles/magnitude * 1.6"
    variables = stub(Array, :size => 2)
    @assertion = OpenEHR::AM::Archetype::Assertion::Assertion.new(:tag => 'validity',
                               :expression => expression,
                               :string_expression => $string_expression,
                               :variables => variables)
  end

  it 'should be an instance of Assertion' do
    @assertion.should be_an_instance_of OpenEHR::AM::Archetype::Assertion::Assertion
  end

  it 'expression should be assigned properly' do
    @assertion.expression.type.should == 'Boolean'
  end

  it 'should raise ArgumentError when expression is nil' do
    lambda {
      @assertion.expression = nil
    }.should raise_error ArgumentError
  end

  it 'should raise ArgumentError when expression type is not Boolean' do
    invalid_expression = stub(ExprItem, :type => 'Real')
    lambda {
      @assertion.expression = invalid_expression
    }.should raise_error ArgumentError
  end

  it 'tag should be assigned properly' do
    @assertion.tag.should == 'validity'
  end

  it 'tag should not be empty' do
    lambda {
      @assertion.tag = ''
    }.should raise_error ArgumentError
  end

  it 'should not raise ArgumentError when tag = nil' do
    lambda {
      @assertion.tag = nil
    }.should_not raise_error ArgumentError
  end

  it 'string_expression should be assigned properly' do
    @assertion.string_expression.should == $string_expression
  end

  it 'variables should be assigned properly' do
    @assertion.variables.size.should be_equal 2
  end
end
