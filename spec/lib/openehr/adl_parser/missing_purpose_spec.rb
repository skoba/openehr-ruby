# ticket 181
require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/parser_spec_helper'

describe ADLParser do
  context 'Missing purpose' do
    before(:all) do
      @archetype = adl14_archetype('adl-test-entry.archetype_desc_missing_purpose.test.adl')
    end

    it 'is an instance of Archetype' do
      expect(@archetype).to be_an_instance_of OpenEHR::AM::Archetype::Archetype
    end

# If porpose in description section was nil, __unknown__ is altered
# for backward compatibility

    it 'purpose is __unknown__' do
      expect(@archetype.description.details['en'].purpose).to eq('__unknown__')
    end
  end
end

