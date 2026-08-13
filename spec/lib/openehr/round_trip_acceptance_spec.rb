require File.dirname(__FILE__) + '/../../spec_helper'
require File.dirname(__FILE__) + '/adl_parser/parser_spec_helper'
require File.dirname(__FILE__) + '/archetype_equivalence_helper'
require 'tempfile'

# The integrated acceptance test for the 2.2.0 serializer/parser
# completeness work (B1-B4): a single archetype exercising uid,
# specialise-adjacent metadata, translations, an invariant, a
# C_DV_QUANTITY constraint, an ARCHETYPE_SLOT with a real assertion,
# and ontology term_bindings, round-tripped through both directions -
# ADL -> AOM -> XML -> AOM (ADLParser -> XMLSerializer ->
# XMLArchetypeParser) and ADL -> AOM -> ADL -> AOM (ADLParser ->
# ADLSerializer -> ADLParser) - checked for structural equivalence
# against the ADLParser-built original via expect_equivalent_archetypes.
describe 'round trip: ADL -> AOM -> XML -> AOM and ADL -> AOM -> ADL -> AOM' do
  let(:fixture) { 'adl-test-entry.round_trip_complete.test.adl' }
  let(:original) { adl14_archetype(fixture) }

  def via_tempfile(text, suffix)
    tempfile = Tempfile.new(['round_trip_complete', suffix])
    tempfile.write(text)
    tempfile.close
    yield tempfile.path
  ensure
    tempfile&.unlink
  end

  describe 'via XMLSerializer -> XMLArchetypeParser' do
    let(:reparsed) do
      xml = OpenEHR::Serializer::XMLSerializer.new(original).merge
      via_tempfile(xml, '.xml') { |path| OpenEHR::Parser::XMLArchetypeParser.new(path).parse }
    end

    it 'is structurally equivalent to the original' do
      expect_equivalent_archetypes(original, reparsed)
    end

    it 'preserves uid, translations, and the invariant' do
      expect(reparsed.uid.value).to eq(original.uid.value)
      expect(reparsed.translations.keys).to eq(original.translations.keys)
      expect(reparsed.invariants.map(&:string_expression)).to eq(original.invariants.map(&:string_expression))
    end

    it 'preserves the C_DV_QUANTITY constraint and the ARCHETYPE_SLOT assertion' do
      items_children = reparsed.definition.attributes.first.children
      element_node = items_children.find { |c| c.is_a?(OpenEHR::AM::Archetype::ConstraintModel::CComplexObject) }
      slot_node = items_children.find { |c| c.is_a?(OpenEHR::AM::Archetype::ConstraintModel::ArchetypeSlot) }
      quantity_node = element_node.attributes.first.children.first

      expect(quantity_node).to be_an_instance_of(OpenEHR::AM::OpenEHRProfile::DataTypes::Quantity::CDvQuantity)
      expect(quantity_node.property.code_string).to eq('128')
      expect(quantity_node.assumed_value.magnitude).to eq(8.0)
      expect(slot_node.includes.first.expression).to be_an_instance_of(OpenEHR::AM::Archetype::Assertion::ExprBinaryOperator)
    end

    it 'preserves ontology term_bindings' do
      expect(reparsed.ontology.term_bindings['SNOMED-CT']['at0004'].first.code_string).to eq(
        original.ontology.term_bindings['SNOMED-CT']['at0004'].first.code_string)
    end
  end

  describe 'via ADLSerializer -> ADLParser' do
    let(:reparsed) do
      adl = OpenEHR::Serializer::ADLSerializer.new(original).merge
      via_tempfile(adl, '.adl') { |path| OpenEHR::Parser::ADLParser.new(path).parse }
    end

    it 'is structurally equivalent to the original' do
      expect_equivalent_archetypes(original, reparsed)
    end

    it 'preserves uid, translations, and the invariant' do
      expect(reparsed.uid.value).to eq(original.uid.value)
      expect(reparsed.translations.keys).to eq(original.translations.keys)
      expect(reparsed.invariants.map(&:string_expression)).to eq(original.invariants.map(&:string_expression))
    end

    it 'preserves ontology term_bindings' do
      expect(reparsed.ontology.term_bindings['SNOMED-CT']['at0004'].first.code_string).to eq(
        original.ontology.term_bindings['SNOMED-CT']['at0004'].first.code_string)
    end
  end
end
