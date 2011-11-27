require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/parser_spec_helper'

# ticket 167

describe ADLParser do
  context 'Archetype uncommon keys' do
    before(:all) do
      archetype = adl14_archetype('adl-test-entry.archetype_uncommonkeys.test.adl')
      @aterm = archetype.ontology.term_definition(:lang => 'en', :code => 'at0000')
    end

    it 's anotherkey value is another key value' do
      @aterm.items['anotherkey'].should == 'another key value'
    end

    it 's text value is test text' do
      @aterm.items['text'].should == 'test text'
    end

    it 's description is test description' do
      @aterm.items['description'].should == 'test description'
    end
  end
end
