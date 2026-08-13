require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/../adl_parser/parser_spec_helper'
require 'tempfile'
include OpenEHR::AM::OpenEHRProfile::DataTypes::Quantity

# XMLArchetypeParser reads the canonical shape XMLSerializer emits (see
# that file's header comment for provenance). The strongest available
# verification is round-tripping real archetypes already used
# elsewhere for ADL round-trip coverage: ADLParser -> XMLSerializer ->
# XMLArchetypeParser, checked against the ADLParser-built original.
describe OpenEHR::Parser::XMLArchetypeParser do
  def round_trip(file)
    archetype = adl14_archetype(file)
    xml = OpenEHR::Serializer::XMLSerializer.new(archetype).merge

    tempfile = Tempfile.new(['xml_archetype_parser', '.xml'])
    tempfile.write(xml)
    tempfile.close
    begin
      OpenEHR::Parser::XMLArchetypeParser.new(tempfile.path).parse
    ensure
      tempfile.unlink
    end
  end

  describe 'a minimal archetype' do
    let(:original) { adl14_archetype('openEHR-EHR-CLUSTER.anatomical_location.v1.adl') }
    let(:reparsed) { round_trip('openEHR-EHR-CLUSTER.anatomical_location.v1.adl') }

    it 'reads archetype_id, concept, and original_language' do
      expect(reparsed.archetype_id.value).to eq(original.archetype_id.value)
      expect(reparsed.concept).to eq(original.concept)
      expect(reparsed.original_language.code_string).to eq(original.original_language.code_string)
    end

    it 'reads uid' do
      expect(original.uid.value).to eq('2fe9e9f8-adfd-4406-878a-82b38ef498a9')
      expect(reparsed.uid.value).to eq(original.uid.value)
    end

    it 'reads a definition tree with the same physical_paths and valid node_ids, including its slots' do
      expect(reparsed.physical_paths.sort).to eq(original.physical_paths.sort)
      expect(reparsed.node_ids_valid?).to be true
      expect(reparsed.definition.rm_type_name).to eq('CLUSTER')
    end

    it 'preserves description purpose text' do
      expect(reparsed.description.details['en'].purpose).to eq(original.description.details['en'].purpose)
    end

    it 'preserves ontology term_definitions across all languages' do
      expect(reparsed.ontology.term_definitions.keys.sort).to eq(original.ontology.term_definitions.keys.sort)
      expect(reparsed.ontology.term_definition(lang: 'en', code: 'at0000').items).to eq(
        original.ontology.term_definition(lang: 'en', code: 'at0000').items)
    end
  end

  describe 'a specialised archetype' do
    it 'reads parent_archetype_id and is_specialised?' do
      original = adl14_archetype('openEHR-EHR-CLUSTER.exam-uterus.v1.adl')
      reparsed = round_trip('openEHR-EHR-CLUSTER.exam-uterus.v1.adl')

      expect(original).to be_is_specialised
      expect(reparsed.parent_archetype_id.value).to eq(original.parent_archetype_id.value)
    end
  end

  describe 'translations' do
    it 'reads each language with its author/accreditation/other_details' do
      original = adl14_archetype('adl-test-entry.archetype_language.test.adl')
      reparsed = round_trip('adl-test-entry.archetype_language.test.adl')

      expect(reparsed.translations.keys.sort).to eq(original.translations.keys.sort)
      expect(reparsed.translations['de'].accreditation).to eq(original.translations['de'].accreditation)
      expect(reparsed.translations['de'].author).to eq(original.translations['de'].author)
      expect(reparsed.translations['de'].other_details).to eq(original.translations['de'].other_details)
    end
  end

  describe 'invariant' do
    it 'reads each assertion string_expression' do
      original = adl14_archetype('adl-test-entry.invariant.test.adl')
      reparsed = round_trip('adl-test-entry.invariant.test.adl')

      expect(original.invariants.map(&:string_expression)).to eq(['inv1:1>0'])
      expect(reparsed.invariants.map(&:string_expression)).to eq(original.invariants.map(&:string_expression))
    end
  end

  describe 'constraint_definitions and constraint_bindings' do
    it 'reads both back from the ontology' do
      original = adl14_archetype('adl-test-entry.archetype_bindings.test.adl')
      reparsed = round_trip('adl-test-entry.archetype_bindings.test.adl')

      expect(reparsed.ontology.constraint_definitions['en']['ac0001'].items).to eq(
        original.ontology.constraint_definitions['en']['ac0001'].items)
      expect(reparsed.ontology.constraint_bindings['SNOMED-CT']['ac0001'].value).to eq(
        original.ontology.constraint_bindings['SNOMED-CT']['ac0001'].value)
      expect(reparsed.ontology.term_bindings['SNOMED-CT']['at0002'].first.code_string).to eq(
        original.ontology.term_bindings['SNOMED-CT']['at0002'].first.code_string)
    end
  end

  describe 'C_DV_QUANTITY' do
    it 'reads property, list, and assumed_value' do
      original = adl14_archetype('adl-test-entry.c_dv_quantity_full.test.adl')
      reparsed = round_trip('adl-test-entry.c_dv_quantity_full.test.adl')

      def find_cdv_quantity(node)
        return node if node.is_a?(OpenEHR::AM::OpenEHRProfile::DataTypes::Quantity::CDvQuantity)
        return nil unless node.respond_to?(:attributes) && node.attributes

        node.attributes.each do |attribute|
          (attribute.children || []).each do |child|
            found = find_cdv_quantity(child)
            return found if found
          end
        end
        nil
      end

      original_node = find_cdv_quantity(original.definition)
      reparsed_node = find_cdv_quantity(reparsed.definition)

      expect(reparsed_node.property.code_string).to eq(original_node.property.code_string)
      expect(reparsed_node.list.size).to eq(original_node.list.size)
      expect(reparsed_node.list.first.units).to eq(original_node.list.first.units)
      expect(reparsed_node.list.first.magnitude.lower).to eq(original_node.list.first.magnitude.lower)
      expect(reparsed_node.assumed_value.magnitude).to eq(original_node.assumed_value.magnitude)
    end
  end

  describe 'error handling' do
    it 'raises a ParseError (not a raw NoMethodError) for a file with no <archetype> root' do
      tempfile = Tempfile.new(['bad', '.xml'])
      tempfile.write('<not_an_archetype/>')
      tempfile.close
      begin
        expect { OpenEHR::Parser::XMLArchetypeParser.new(tempfile.path).parse }.to raise_error(OpenEHR::Parser::ParseError)
      ensure
        tempfile.unlink
      end
    end

    it 'raises a ParseError for an unknown xsi:type in the definition tree' do
      xml = <<~XML
        <?xml version='1.0' encoding='UTF-8'?>
        <archetype xmlns="http://schemas.openehr.org/v1" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
          <archetype_id><value>openEHR-EHR-CLUSTER.bad.v1</value></archetype_id>
          <concept>at0000</concept>
          <original_language>
            <terminology_id><value>ISO_639-1</value></terminology_id>
            <code_string>en</code_string>
          </original_language>
          <description>
            <original_author id="name">Someone</original_author>
            <lifecycle_state>Initial</lifecycle_state>
            <details>
              <detail language="en">
                <language>
                  <terminology_id><value>ISO_639-1</value></terminology_id>
                  <code_string>en</code_string>
                </language>
                <purpose>test</purpose>
              </detail>
            </details>
          </description>
          <definition>
            <rm_type_name>CLUSTER</rm_type_name>
            <occurrences>
              <lower_included>true</lower_included><upper_included>true</upper_included>
              <lower_unbounded>false</lower_unbounded><upper_unbounded>false</upper_unbounded>
              <lower>1</lower><upper>1</upper>
            </occurrences>
            <node_id>at0000</node_id>
            <attributes xsi:type="C_SINGLE_ATTRIBUTE">
              <rm_attribute_name>value</rm_attribute_name>
              <existence>
                <lower_included>true</lower_included><upper_included>true</upper_included>
                <lower_unbounded>false</lower_unbounded><upper_unbounded>false</upper_unbounded>
                <lower>1</lower><upper>1</upper>
              </existence>
              <children xsi:type="C_SOMETHING_UNKNOWN">
                <rm_type_name>DV_TEXT</rm_type_name>
              </children>
            </attributes>
          </definition>
          <ontology>
            <specialisation_depth>0</specialisation_depth>
            <term_definitions language="en" code="at0000">
              <items id="text">bad</items>
              <items id="description">bad</items>
            </term_definitions>
          </ontology>
        </archetype>
      XML

      tempfile = Tempfile.new(['bad_xsi_type', '.xml'])
      tempfile.write(xml)
      tempfile.close
      begin
        expect { OpenEHR::Parser::XMLArchetypeParser.new(tempfile.path).parse }.to raise_error(OpenEHR::Parser::ParseError)
      ensure
        tempfile.unlink
      end
    end
  end
end
