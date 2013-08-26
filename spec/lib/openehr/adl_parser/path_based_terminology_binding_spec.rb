# ticket 188
require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/parser_spec_helper'

describe ADLParser do
  context 'term bindings spec' do
    before(:all) do
      archetype = adl14_archetype('adl-test-entry.term_binding2.test.adl')
      @item = archetype.ontology.term_bindings['LNC205']
    end

    it 'key is path' do
      @item.should have_key '/data[at0002]/events[at0003]/data[at0001]/item[at0004]'
    end

    context 'term' do
      before(:all) do
        @term = @item['/data[at0002]/events[at0003]/data[at0001]/item[at0004]'][0]
      end

      it 'terminology id is LNC205' do
        @term.terminology_id.name.should == 'LNC205'
      end

      it 'code is 8310-5' do
        @term.code_string.should == '8310-5'
      end
    end
  end
end
