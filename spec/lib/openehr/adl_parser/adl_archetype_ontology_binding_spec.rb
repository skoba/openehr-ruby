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
      expect(@ontology).to be_an_instance_of ArchetypeOntology
    end

    it 's terminolgies available are SNOMED-CT' do
      expect(@ontology.terminologies_available).to eq(['SNOMED-CT'])
    end
    it 'has SNOMED-CT coding' do
      expect(@ontology).to have_terminology 'SNOMED-CT'
    end

    context 'term definitions, language en, code at0000' do
      before(:all) do
        @term_def = @ontology.term_definition(:lang => 'en',
                                              :code => 'at0000')
      end

      it 's code is at0000' do
        expect(@term_def.code).to eq('at0000')
      end

      it 's item text is test' do
        expect(@term_def.items['text']).to eq('test')
      end

      it 's item description is test' do
        expect(@term_def.items['description']).to eq('test')
      end
    end

    context 'constraint definitions' do
      before(:all) do
        @const_def = @ontology.constraint_definition(:lang => 'en',
                                                     :code => 'ac0001')
      end

      it 's code is at0001' do
        expect(@const_def.code).to eq('ac0001')
      end

      it 's items text is test constraint' do
        expect(@const_def.items['text']).to eq('test constraint') 
      end

      it 's items description is *' do
        expect(@const_def.items['description']).to eq('*')
      end
    end

    context 'term_bindings' do
      before(:all) do
        @term_bindings = @ontology.term_bindings
      end

      it 'key is SNOMED-CT' do
        expect(@term_bindings.keys).to eq(['SNOMED-CT'])
      end

      it 's code is at0002' do
        expect(@term_bindings['SNOMED-CT'].keys).to eq(['at0002'])
      end

      context 'SNOMED-CT terminology, code is at0002' do
        before(:all) do
          @term = @ontology.
            term_binding(:terminology => 'SNOMED-CT', :code => 'at0002')
        end

        it 'terminology id is SNOMED-CT' do
          expect(@term[0].terminology_id.value).to eq('SNOMED-CT')
        end

        it 'code_string is 123456' do
          expect(@term[0].code_string).to eq('123456')
        end
      end
    end

    context 'constraint bindings' do
      it 'terminology SNOMED-CT, constraint code is ac0001' do
        expect(@ontology.constraint_binding(:terminology => 'SNOMED-CT',
                                     :code => 'ac0001').value).to eq(
          'http://openEHR.org/testconstraintbinding'
        )
      end
    end
  end
end
