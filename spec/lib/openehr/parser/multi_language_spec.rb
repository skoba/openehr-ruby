require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/parser_spec_helper'
include ::OpenEHR::RM::DataTypes::Text

describe ADLParser do
  context do
    before(:all) do
      archetype = adl14_archetype('adl-test-entry.multi_language.test.adl')
      @ontology = archetype.ontology
    end

    it 'primary language is en' do
      @ontology.primary_language.should == 'en'
    end

    it 'languages available are sv and en' do
      @ontology.languages_available.should == ['en', 'sv']
    end

    context 'term definition' do
      before(:all) do
        @term_def = @ontology.term_definitions
      end

      it 'languages defined are sv and en' do
        @term_def.keys.should == ['en','sv']
      end

      context 'en items' do
        before(:all) do
          @en = @term_def['en']['at0000'].items
        end

        it 'text is most minimal' do
          @en['text'].should == 'most minimal'
        end

        it 'description is most minimal' do
          @en['description'].should == 'most minimal'
        end
      end

      context 'sv items' do
        before(:all) do
          @en = @term_def['sv']['at0000'].items
        end

        it 'text is most minimal' do
          @en['text'].should == 'mesta minimal'
        end

        it 'description is most minimal' do
          @en['description'].should == 'mesta minimal'
        end
      end
    end
  end
end
