require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/parser_spec_helper'
include OpenEHR::AM::Archetype::Ontology

describe ADLParser do
  context 'ArchetypeOntology' do
    before(:all) do
      at = adl14_archetype('adl-test-entry.archetype_bindings.test.adl')
      @ontology = at.ontology
    end

    it 'is an instance of ArchetypeOntology' do
      @ontology.should be_an_instance_of ArchetypeOntology
    end

    it 's terminolgies available are SNOMED-CT' do
      @ontology.terminologies_available.should == ['SNOMED-CT']
    end
    it 'has SNOMED-CT coding' do
      @ontology.should have_terminology 'SNOMED-CT'
    end

    context 'term definitions, language en, code at0000' do
      before(:all) do
        @term_def = @ontology.term_definition(:lang => 'en',
                                              :code => 'at0000')
      end

      it 's code is at0000' do
        @term_def.code.should == 'at0000'
      end

      it 's item text is test' do
        @term_def.items['text'].should == 'test'
      end

      it 's item description is test' do
        @term_def.items['description'].should == 'test'
      end
    end

    context 'constraint definitions' do
      before(:all) do
        @const_def = @ontology.constraint_definition(:lang => 'en',
                                                     :code => 'ac0001')
      end

      it 's code is at0001' do
        @const_def.code.should == 'ac0001'
      end

      it 's items text is test constraint' do
        @const_def.items['text'].should == 'test constraint' 
      end

      it 's items description is *' do
        @const_def.items['description'].should == '*'
      end
    end

    context 'term_bindings' do
      before(:all) do
        @term_bindings = @ontology.term_bindings
      end

      it 'key is SNOMED-CT' do
        @term_bindings.keys.should == ['SNOMED-CT']
      end

      it 's code is at0002' do
        @term_bindings['SNOMED-CT'].keys.should == ['at0002']
      end

      context 'SNOMED-CT terminology, code is at0002' do
        before(:all) do
          @term = @ontology.
            term_binding(:terminology => 'SNOMED-CT', :code => 'at0002')
        end

        it 'terminology id is SNOMED-CT' do
          @term[0].terminology_id.value.should == 'SNOMED-CT'
        end

        it 'code_string is 123456' do
          @term[0].code_string.should == '123456'
        end
      end
    end

    context 'constraint bindings' do
      it 'terminology SNOMED-CT, constraint code is ac0001' do
        @ontology.constraint_binding(:terminology => 'SNOMED-CT',
                                     :code => 'ac0001').value.should ==
          'http://openEHR.org/testconstraintbinding'
      end
    end
  end
end
