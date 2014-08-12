require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/parser_spec_helper'
include OpenEHR::AM::Archetype

# ticket 169
# almost same as adl_archetype_internal_ref_with_generics_spec.rb

describe ADLParser do
  context 'Basic Generic type' do
    before(:all) do
      @archetype = adl14_archetype('adl-test-SOME_TYPE.generic_type_basic.draft.adl')
    end

    it 'is an instance of Archetype' do
      expect(@archetype).to be_an_instance_of Archetype
    end
  end
end
