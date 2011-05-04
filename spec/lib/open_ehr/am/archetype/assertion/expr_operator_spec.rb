require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::AM::Archetype::Assertion

describe ExprOperator do
  before(:each) do
    operator = OperatorKind.new(:value => 2001)
    @expr_operator = ExprOperator.new(:type => 'Integer',
                                      :item => 'ANY',
                                      :reference_type => 'operator',
                                      :operator => operator,
                                      :precedence_overridden => true)
  end

  it 'should be an instance of ExprOperator' do
    @expr_operator.should be_an_instance_of ExprOperator
  end

  it 'operator should be assigned properly' do
    @expr_operator.operator.value.should be_equal 2001
  end

  it 'precedence_overridden should be assigned properly' do
    @expr_operator.precedence_overridden.should be_true
  end
end
