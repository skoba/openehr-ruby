# ticket #175
require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/parser_spec_helper'

describe ADLParser do
  context 'Constraint Bindings' do
    before(:all) do
      at = adl14_archetype('adl-test-entry.constraint_binding.test.adl')
      @ao = at.ontology
    end

    it 'contraint bindings size is two' do
      @ao.constraint_bindings.size.should be 2
    end

    it 'SNOMED_CT binds local ac0001 to http://terminology.org/?terminology_id=snomed_ct&&has_relation=102002;with_target=128004' do
      @ao.constraint_binding(:terminology => 'SNOMED_CT', :code => 'ac0001').
        value.should == 'http://terminology.org?terminology_id=snomed_ct&&has_relation=102002;with_target=128004'
    end

    it 'ICD10 binds local ac0001 to http://terminology.org/?terminology_id=icd10&&has_relation=a2;with_target=b19' do
      @ao.constraint_binding(:terminology => 'ICD10', :code => 'ac0001').
        value.should == 'http://terminology.org?terminology_id=icd10&&has_relation=a2;with_target=b19'
    end
  end
end
