require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/sample_archetype_fixture'
require 'rexml/document'
include OpenEHR::Serializer

# The canonical shape asserted here (occurrences plural, xsi:type
# dispatch on attributes/children, attribute-style term_definitions)
# is verified against this gem's own OPTParser (which reads real
# Ocean Template Designer .opt fixtures) in
# spec/lib/openehr/serializer/xml_definition_serializer_spec.rb and
# opt_parser_definition_round_trip_spec.rb.
describe XMLSerializer do
  before(:all) do
    @archetype = sample_archetype
  end

  before(:each) do
    @xml_serializer = XMLSerializer.new(@archetype)
  end

  def doc(fragment)
    REXML::Document.new("<root xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">#{fragment}</root>")
  end

  it 'should be an instance of XMLSerializer' do
    expect(@xml_serializer).to be_an_instance_of XMLSerializer
  end

  describe '#header' do
    it 'includes archetype_id, concept, and original_language' do
      header_doc = doc(@xml_serializer.header)
      expect(REXML::XPath.first(header_doc, '//archetype_id/value').text).to eq('openEHR-EHR-SECTION.test.v1')
      expect(REXML::XPath.first(header_doc, '//original_language/terminology_id/value').text).to eq('ISO_639-1')
      expect(REXML::XPath.first(header_doc, '//original_language/code_string').text).to eq('ja')
    end

    it 'omits uid/adl_version/parent_archetype_id/translations when absent' do
      header_doc = doc(@xml_serializer.header)
      expect(REXML::XPath.first(header_doc, '//uid')).to be_nil
      expect(REXML::XPath.first(header_doc, '//adl_version')).to be_nil
      expect(REXML::XPath.first(header_doc, '//parent_archetype_id')).to be_nil
      expect(REXML::XPath.first(header_doc, '//translations')).to be_nil
    end
  end

  describe '#description' do
    it 'includes original_author, lifecycle_state, and per-language details' do
      desc_doc = doc(@xml_serializer.description)
      expect(REXML::XPath.first(desc_doc, "//original_author[@id='name']").text).to eq('Shinji KOBAYASHI')
      expect(REXML::XPath.first(desc_doc, '//lifecycle_state').text).to eq('draft')
      expect(REXML::XPath.first(desc_doc, "//details/detail[@language='ja']/purpose").text).to eq('Serializer test')
      expect(REXML::XPath.first(desc_doc, "//details/detail[@language='ja']/misuse").text).to eq('evaluate message')
    end
  end

  describe '#definition' do
    it 'renders an any_allowed root with no attributes element' do
      def_doc = doc(@xml_serializer.definition)
      expect(REXML::XPath.first(def_doc, '//definition/rm_type_name').text).to eq('SECTION')
      expect(REXML::XPath.first(def_doc, '//definition/occurrences')).not_to be_nil
      expect(REXML::XPath.first(def_doc, '//definition/attributes')).to be_nil
    end
  end

  describe '#ontology' do
    it 'includes specialisation_depth and attribute-style term_definitions' do
      ont_doc = doc(@xml_serializer.ontology)
      expect(REXML::XPath.first(ont_doc, '//ontology/specialisation_depth').text).to eq('0')
      term_def = REXML::XPath.first(ont_doc, "//term_definitions[@language='ja'][@code='at0000']")
      expect(term_def).not_to be_nil
      expect(REXML::XPath.first(term_def, "items[@id='text']").text).to eq('simple test')
      expect(REXML::XPath.first(term_def, "items[@id='description']").text).to eq('simple test for serializer')
    end
  end

  describe '#merge' do
    it 'produces a single well-formed XML document' do
      xml = nil
      expect { xml = REXML::Document.new(@xml_serializer.merge) }.not_to raise_error
      expect(xml.root.name).to eq('archetype')
    end
  end
end
