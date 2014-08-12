require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::AM::Archetype::Assertion

describe ExprUnaryOperator do
  before(:each) do
    operator = OperatorKind.new(:value => 2001)
    operand = double(ExprItem, :type => 'Real')
    @expr_unary_operator =
      ExprUnaryOperator.new(:type => 'Integer',
                            :item => 'ANY',
                            :reference_type => 'operator',
                            :operator => operator,
                            :precedence_overridden => true,
                            :operand => operand)
  end

  it 'operand shoud be assigned properly' do
    expect(@expr_unary_operator.operand.type).to eq('Real')
  end

  it 'should raise ArgumentError when operand is nil' do
    expect {
      @expr_unary_operator.operand = nil
    }.to raise_error ArgumentError
  end
end
