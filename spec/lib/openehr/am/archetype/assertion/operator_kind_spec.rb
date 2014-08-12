require File.dirname(__FILE__) + '/../../../../../spec_helper'
include OpenEHR::AM::Archetype::Assertion

describe OperatorKind do
  it 'op_eq should be equal 2001' do
    expect(OperatorKind::OP_EQ).to be_equal 2001
  end

  it 'op_ne should be equal 2002' do
    expect(OperatorKind::OP_NE).to be_equal 2002
  end

  it 'op_le should be equal 2004' do
    expect(OperatorKind::OP_LE).to be_equal 2003
  end

  it 'op_lt should be equal 2004' do
    expect(OperatorKind::OP_LT).to be_equal 2004
  end

  it 'op_ge should be equal 2005' do
    expect(OperatorKind::OP_GE).to be_equal 2005
  end

  it 'op_gt should be equal 2006' do
    expect(OperatorKind::OP_GT).to be_equal 2006
  end

  it 'op_matches should be equal 2007' do
    expect(OperatorKind::OP_MATCHES).to be_equal 2007
  end

  it 'op_not should be equal 2010' do
    expect(OperatorKind::OP_NOT).to be_equal 2010
  end

  it 'op_and should be equal 2011' do
    expect(OperatorKind::OP_AND).to be_equal 2011
  end

  it 'op_or should be equal 2012' do
    expect(OperatorKind::OP_OR).to be_equal 2012
  end

  it 'op_xor should be equal 2013' do
    expect(OperatorKind::OP_XOR).to be_equal 2013
  end

  it 'op_implies should be equal 2014' do
    expect(OperatorKind::OP_IMPLIES).to be_equal 2014
  end

  it 'op_for_all should be equal 2015' do
    expect(OperatorKind::OP_FOR_ALL).to be_equal 2015
  end

  it 'op_exists should be equal 2016' do
    expect(OperatorKind::OP_EXISTS).to be_equal 2016
  end

  it 'op_plus should be equal 2020' do
    expect(OperatorKind::OP_PLUS).to be_equal 2020
  end

  it 'op_minus should be equal 2021' do
    expect(OperatorKind::OP_MINUS).to be_equal 2021
  end

  it 'op_multiply should be equal 2022' do
    expect(OperatorKind::OP_MULTIPLY).to be_equal 2022
  end

  it 'op_divide should be equal 2023' do
    expect(OperatorKind::OP_DIVIDE).to be_equal 2023
  end

  it 'op_exp should be equal 2024' do
    expect(OperatorKind::OP_EXP).to be_equal 2024
  end

  it '2000 should not be valid operator' do
    expect(OperatorKind).not_to be_valid_operator 2000
  end

  it '2001 should be valid operator' do
    expect(OperatorKind).to be_valid_operator 2001
  end

  it '2024 should be valid operator' do
    expect(OperatorKind).to be_valid_operator 2024
  end

  it '2025 should not be valid operator' do
    expect(OperatorKind).not_to be_valid_operator 2025
  end

  describe 'value should be assigned' do
    before(:each) do
      @operator_kind = OperatorKind.new(:value => 2001)
    end

    it 'value should be assigned' do
      expect(@operator_kind.value).to be_equal 2001
    end

    it 'should raise ArgumentError with invalid value' do
      expect {
        @operator_kind.value = 10001
      }.to raise_error ArgumentError
    end
  end
end
  
    
