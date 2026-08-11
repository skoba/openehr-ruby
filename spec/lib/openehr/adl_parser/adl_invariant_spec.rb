require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/parser_spec_helper'

describe 'ADL invariant section' do
  def parse_rule(rule, input)
    parser = OpenEHR::Parser::ADLGrammarParser.new
    parser.root = rule
    parser.parse(input)
  end

  describe 'arch_invariant rule in isolation' do
    it 'exposes the parsed assertions as its value' do
      result = parse_rule(:arch_invariant, "invariant\n\tinv1:1>0\n")
      expect(result).not_to be_nil
      expect(result.value).to be_an(Array)
      expect(result.value.size).to eq(1)
      expect(result.value.first).to be_an_instance_of OpenEHR::AM::Archetype::Assertion::Assertion
      expect(result.value.first.tag).to eq('inv1')
    end
  end

  describe 'a full archetype with an invariant section' do
    let(:archetype) { adl14_archetype('adl-test-entry.invariant.test.adl') }

    it 'retains the invariants instead of discarding them' do
      expect(archetype.invariants).not_to be_nil
      expect(archetype.invariants.size).to eq(1)
      expect(archetype.invariants.first.tag).to eq('inv1')
    end
  end

  describe 'a full archetype with no invariant section' do
    let(:archetype) { adl14_archetype('openEHR-EHR-CLUSTER.anatomical_location.v1.adl') }

    it 'has nil invariants' do
      expect(archetype.invariants).to be_nil
    end
  end
end
