require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::AM::Archetype::Assertion

describe ExprBinaryOperator do
  before(:each) do
    operator = OperatorKind.new(:value => 2001)
    right_operand = ExprItem.new(:type => 'Real')
    left_operand = stub(ExprItem, :item => 'ANY')
    @expr_binary_operator =
      ExprBinaryOperator.new(:type => 'Integer',
                             :item => 'ANY',
                             :reference_type => 'operator',
                             :operator => operator,
                             :precedence_overridden => true,
                             :right_operand => right_operand,
                             :left_operand => left_operand)
  end


  it 'right_operand should be assigned properly' do
    @expr_binary_operator.right_operand.type.should == 'Real'
  end

  it 'should raise ArgumentError when right_operand is nil' do
    lambda {
      @expr_binary_operator.right_operand = nil
    }.should raise_error ArgumentError
  end

  it 'left_operand should be assigned properly' do
    @expr_binary_operator.left_operand.item.should == 'ANY'
  end

  it 'should raise ArgumentError when left_oprand is nil' do
    lambda {
      @expr_binary_operator.left_operand = nil
    }.should raise_error ArgumentError
  end
end

