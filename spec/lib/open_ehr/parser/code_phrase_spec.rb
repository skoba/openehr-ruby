require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/parser_spec_helper'

# ticket 171

describe ADLParser do
  context 'CodePhase type' do
    before(:all) do
      archetype = adl14_archetype('adl-test-entry.c_code_phrase.test.adl')
      @attributes = archetype.definition.attributes
    end

    it 'is an array' do
      p @attributes
    end
  end
end
