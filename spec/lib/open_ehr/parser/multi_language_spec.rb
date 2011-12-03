require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/parser_spec_helper'
include ::OpenEHR::RM::DataTypes::Text

describe ADLParser do
  context do
    before(:all) do
      archetype = adl14_archetype('adl-test-entry.multi_language.test.adl')
      @c_code_phrase = archetype.definition.attributes[0].children[0].
        attributes[0].children[0]
    end

    it
  end
end
