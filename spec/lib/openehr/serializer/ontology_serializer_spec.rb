require File.dirname(__FILE__) + '/../../../spec_helper'
require 'rexml/document'
include OpenEHR::Serializer
include OpenEHR::AM::Archetype::Ontology
include OpenEHR::RM::DataTypes::Text
include OpenEHR::RM::Support::Identification

describe 'ADLSerializer#ontology / XMLSerializer#ontology (terminologies_available, languages_available, term_bindings)' do
  let(:archetype_term) { ArchetypeTerm.new(:code => 'at0000', :items => {'text' => 'test'}) }
  let(:binding_code) { CodePhrase.new(:terminology_id => TerminologyID.new(:value => 'SNOMED-CT'), :code_string => '272741003') }
  let(:ontology) do
    ArchetypeOntology.new(:term_definitions => {'en' => {'at0000' => archetype_term}},
                          :languages_available => ['en'],
                          :terminologies_available => ['SNOMED-CT'],
                          :term_bindings => {'SNOMED-CT' => {'at0000' => [binding_code]}})
  end
  let(:archetype) { double('archetype', :ontology => ontology) }

  describe ADLSerializer do
    it 'includes terminologies_available and languages_available' do
      text = ADLSerializer.new(archetype).ontology
      expect(text).to include('languages_available = <"en">')
      expect(text).to include('terminologies_available = <"SNOMED-CT">')
    end

    it 'includes term_bindings' do
      text = ADLSerializer.new(archetype).ontology
      expect(text).to include('term_bindings = <')
      expect(text).to include('["SNOMED-CT"] = <')
      expect(text).to include('["at0000"] = <[SNOMED-CT::272741003]>')
    end
  end

  describe XMLSerializer do
    def doc
      REXML::Document.new("<root>#{XMLSerializer.new(archetype).ontology}</root>")
    end

    it 'includes terminologies_available and languages_available' do
      expect(REXML::XPath.first(doc, '//ontology/languages_available').text).to eq('en')
      expect(REXML::XPath.first(doc, '//ontology/terminologies_available').text).to eq('SNOMED-CT')
    end

    it 'includes term_bindings' do
      binding = REXML::XPath.first(doc, "//ontology/term_bindings[@terminology='SNOMED-CT'][@code='at0000']")
      expect(binding).not_to be_nil
      expect(binding.text).to eq('SNOMED-CT::272741003')
    end
  end
end
