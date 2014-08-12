require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/parser_spec_helper'
include OpenEHR::AM::Archetype::Ontology

describe ADLParser do
  context 'ArchetypeOntology' do
    before(:all) do
      at = adl14_archetype('adl-test-entry.archetype_ontology.test.adl')
      @ontology = at.ontology
    end

    it 'is an instance of ArchetypeOntology' do
      expect(@ontology).to be_an_instance_of ArchetypeOntology
    end

    it 's primary language is en' do
      expect(@ontology.primary_language).to eq('en')
    end

    it 's languages available are en' do
      expect(@ontology.languages_available).to eq(['en'])
    end

    context 'en terms' do
      before(:all) do
        @archetype_term = @ontology.term_definition(:lang => 'en', :code => 'at0000')
      end

      it 's text is some text' do
        expect(@archetype_term.items['text']).to eq('some text')
      end

      it 's description is some description' do
        expect(@archetype_term.items['description']).to eq('some description')
      end

      it 's commen is some comment' do
        expect(@archetype_term.items['comment']).to eq('some comment')
      end
    end
  end
end
