require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/parser_spec_helper'
include OpenEHR::AM::Archetype
include OpenEHR::AM::Archetype::Ontology

describe ADLParser do
  context 'ArchetypeOntology' do
    before(:all) do
      at = adl14_archetype('adl-test-entry.archetype_ontology.test.adl')
      @ontology = at.ontology
    end

    it 'is an instance of ArchetypeOntology' do
      @ontology.should be_an_instance_of ArchetypeOntology
    end

    it 's primary language is en' do
      @ontology.primary_language.should == 'en'
    end

    it 's languages available are en' do
      @ontology.languages_available.should == ['en']
    end

    context 'en terms' do
      before(:all) do
        @archetype_term = @ontology.term_definition(:lang => 'en', :code => 'at0000')
      end

      it 's text is some text' do
        @archetype_term['text'].should == 'some text'
      end

      it 's description is some description' do
        @archetype_term['description'].should == 'some description'
      end

      it 's commen is some comment' do
        @archetype_term['comment'].should == 'some comment'
      end
    end
  end
end
