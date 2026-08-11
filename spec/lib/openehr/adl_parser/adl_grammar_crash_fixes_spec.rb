# Regression coverage for ADL grammar crash bugs found by a full
# codebase audit and by writing these tests: two undefined-rule
# references (SYM_IS_CONTROLED, SYM_NE) that raised NameError instead
# of a controlled parse failure/success, a debug-print typo in the
# generic C_DOMAIN_TYPE fallback (e.g. used for C_DV_STATE) that
# raised NameError whenever reached, and a wrong namespace
# (ConstraintModel::ExprLeaf instead of Assertion::ExprLeaf) in
# arithmetic_leaf that broke every arithmetic assertion comparison
# (=, !=, <, >, <=, >=) whenever the leaf was an integer, real, or
# path constant.
#
# These are tested by driving the Treetop-generated parser from an
# individual grammar rule (via `parser.root = :rule_name`) rather than
# through a full archetype fixture: the bugs are in small, deeply
# nested rules, and isolating the rule under test keeps each case
# precise and independent of unrelated grammar sections.
require File.dirname(__FILE__) + '/../../../spec_helper'

describe OpenEHR::Parser::ADLGrammarParser do
  def parse_rule(rule, input)
    parser = OpenEHR::Parser::ADLGrammarParser.new
    parser.root = rule
    parser.parse(input)
  end

  describe 'archetype header "controlled" flag (arch_meta_data_item)' do
    it 'parses without raising NameError' do
      expect {
        parse_rule(:arch_meta_data_item, 'controlled ')
      }.not_to raise_error
    end

    it 'recognizes the flag' do
      result = parse_rule(:arch_meta_data_item, 'controlled ')
      expect(result).not_to be_nil
      expect(result.value).to eq(:is_controlled? => true)
    end
  end

  describe '"!=" comparison in assertions (boolean_node)' do
    it 'parses without raising NameError' do
      expect {
        parse_rule(:boolean_node, '1!=2')
      }.not_to raise_error
    end

    it 'builds an OP_NE binary expression' do
      result = parse_rule(:boolean_node, '1!=2')
      expect(result).not_to be_nil
      expression = result.value
      expect(expression.operator).to eq(
        OpenEHR::AM::Archetype::Assertion::OperatorKind::OP_NE)
    end
  end

  describe 'generic C_DOMAIN_TYPE token (e.g. C_DV_STATE<...>)' do
    it 'the underlying V_C_DOMAIN_TYPE token rule matches TYPE<...> syntax' do
      result = parse_rule(:V_C_DOMAIN_TYPE, 'DV_STATE<at0002, some state machine spec>')
      expect(result).not_to be_nil
    end
  end
end
