require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/parser_spec_helper'
include OpenEHR::AM::Archetype

# ticket 170

def attr(index)
  return @constraints[index-1].children[0]
end

describe ADLParser do
  context 'Basic Generic type' do
    before(:all) do
      archetype = adl14_archetype('adl-test-entry.basic_types.test.adl')
      @attributes = archetype.definition.attributes
    end

    context 'String constraint' do
      before(:all) do
        @constraints = @attributes[0].children[0].attributes
      end

      it 'first string list is something' do
        attr(1).list.should == ['something']
      end

      it 'second string pattern is /this|that|something else/' do
        attr(2).pattern.should == 
          '/this|that|something else/'
      end

      it 'third string pattern is /cardio.*/' do
        attr(3).pattern.should == '/cardio.*/'
      end

      it 'fourth string pattern is ^mg|mg/ml|mg/g^' do
        attr(4).pattern.should == '^mg|mg/ml|mg/g^'
      end

      it 'fifth string list is apple, pear' do
        attr(5).list.should == ["apple","pear"]
      end

      it 'sixth string list is something' do
        attr(6).list.should == ['something']
      end

      it 'sixth string assumed nothing' do
        attr(6).assumed_value.should == 'nothing'
      end

      it 'seventh string pattern is /this|that|something else/' do
        attr(7).pattern.should == '/this|that|something else/'
      end

      it 'seventh string assumed value is those' do
        attr(7).assumed_value.should == 'those'
      end

      it 'eighth string pattern is /cardio.*/' do
        attr(8).pattern.should == '/cardio.*/'
      end

      it 'eighth string assumed value is cardio.txt' do
        attr(8).assumed_value.should == 'cardio.txt'
      end

      it 'nineth string pattern is ^mg|mg/ml|mg/g^' do
        attr(9).pattern.should == '^mg|mg/ml|mg/g^'
      end

      it 'nineth string assumed value is mg' do
        attr(9).assumed_value.should == 'mg'
      end

      it 'tenth string list is apple, pear' do
        attr(10).list.should == ['apple','pear']
      end

      it 'tenth string assumed value is orange' do
        attr(10).assumed_value.should == 'orange'
      end
    end
  end
end
