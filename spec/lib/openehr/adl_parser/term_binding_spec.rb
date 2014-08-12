# ticket 188
require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/parser_spec_helper'

describe ADLParser do
  context 'term bindings spec' do
    before(:all) do
      archetype = adl14_archetype('adl-test-entry.term_binding.test.adl')
      @ontology = archetype.ontology
    end

    it 'term bindings size are 2 ' do
      expect(@ontology.term_bindings.size).to be 2
    end

    context 'SNOMED_CT' do
      before(:all) do
        @tb = @ontology.term_binding(:terminology => 'SNOMED_CT',
                                     :code => 'at0000')
      end

      it 'at0000 binds to snomed_ct terminology' do
        expect(@tb[0].terminology_id.name).to eq('snomed_ct')
      end

      it 'at0000 binds code string 1000339' do
        expect(@tb[0].code_string).to eq('1000339')
      end
    end

    context 'ICD10' do
      before(:all) do
        @tb = @ontology.term_binding(:terminology => 'ICD10',
                                     :code => 'at0000')
      end

      it 'terminology binding list contains 2' do
        expect(@tb.size).to be 2
      end

      it 'terminology id is icd10' do
        expect(@tb[0].terminology_id.name).to eq('icd10')
      end

      it 'codestring is 1000' do
        expect(@tb[0].code_string).to eq('1000')
      end

      it '2nd code string is 1001' do
        expect(@tb[1].code_string).to eq('1001')
      end
    end
  end
end
