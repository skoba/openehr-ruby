require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::AM::Archetype::Assertion

describe OperatorKind do
  it 'op_eq should be equal 2001' do
    OperatorKind::OP_EQ.should be_equal 2001
  end

  it 'op_ne should be equal 2002' do
    OperatorKind::OP_NE.should be_equal 2002
  end

  it 'op_le should be equal 2004' do
    OperatorKind::OP_LE.should be_equal 2003
  end

  it 'op_lt should be equal 2004' do
    OperatorKind::OP_LT.should be_equal 2004
  end

  it 'op_ge should be equal 2005' do
    OperatorKind::OP_GE.should be_equal 2005
  end

  it 'op_gt should be equal 2006' do
    OperatorKind::OP_GT.should be_equal 2006
  end

  it 'op_matches should be equal 2007' do
    OperatorKind::OP_MATCHES.should be_equal 2007
  end

  it 'op_not should be equal 2010' do
    OperatorKind::OP_NOT.should be_equal 2010
  end

  it 'op_and should be equal 2011' do
    OperatorKind::OP_AND.should be_equal 2011
  end

  it 'op_or should be equal 2012' do
    OperatorKind::OP_OR.should be_equal 2012
  end

  it 'op_xor should be equal 2013' do
    OperatorKind::OP_XOR.should be_equal 2013
  end

  it 'op_implies should be equal 2014' do
    OperatorKind::OP_IMPLIES.should be_equal 2014
  end

  it 'op_for_all should be equal 2015' do
    OperatorKind::OP_FOR_ALL.should be_equal 2015
  end

  it 'op_exists should be equal 2016' do
    OperatorKind::OP_EXISTS.should be_equal 2016
  end

  it 'op_plus should be equal 2020' do
    OperatorKind::OP_PLUS.should be_equal 2020
  end

  it 'op_minus should be equal 2021' do
    OperatorKind::OP_MINUS.should be_equal 2021
  end

  it 'op_multiply should be equal 2022' do
    OperatorKind::OP_MULTIPLY.should be_equal 2022
  end

  it 'op_divide should be equal 2023' do
    OperatorKind::OP_DIVIDE.should be_equal 2023
  end

  it 'op_exp should be equal 2024' do
    OperatorKind::OP_EXP.should be_equal 2024
  end

  it '2000 should not be valid operator' do
    OperatorKind.should_not be_valid_operator 2000
  end

  it '2001 should be valid operator' do
    OperatorKind.should be_valid_operator 2001
  end

  it '2024 should be valid operator' do
    OperatorKind.should be_valid_operator 2024
  end

  it '2025 should not be valid operator' do
    OperatorKind.should_not be_valid_operator 2025
  end

  describe 'value should be assigned' do
    before(:each) do
      @operator_kind = OperatorKind.new(:value => 2001)
    end

    it 'value should be assigned' do
      @operator_kind.value.should be_equal 2001
    end

    it 'should raise ArgumentError with invalid value' do
      lambda {
        @operator_kind.value = 10001
      }.should raise_error ArgumentError
    end
  end
end
  
    
