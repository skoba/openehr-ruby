require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/parser_spec_helper'
include OpenEHR::AM::Archetype

# ticket 170

def attr(index)
  return @constraints[index-1].children[0]
end

def const(index)
  return @attributes[index].children[0].attributes
end


describe ADLParser do
  context 'Basic Generic type' do
    before(:all) do
      archetype = adl14_archetype('adl-test-entry.basic_types.test.adl')
      @attributes = archetype.definition.attributes
    end

    context 'String constraint' do
      before(:all) do
        @constraints = const(0)
      end

      it 'first attribute list is something' do
        attr(1).list.should == ['something']
      end

      it 'second attribute pattern is /this|that|something else/' do
        attr(2).pattern.should == 
          '/this|that|something else/'
      end

      it 'third attribute pattern is /cardio.*/' do
        attr(3).pattern.should == '/cardio.*/'
      end

      it 'fourth attribute pattern is ^mg|mg/ml|mg/g^' do
        attr(4).pattern.should == '^mg|mg/ml|mg/g^'
      end

      it 'fifth attribute list is apple, pear' do
        attr(5).list.should == ["apple","pear"]
      end

      it 'sixth attribute list is something' do
        attr(6).list.should == ['something']
      end

      it 'sixth attribute assumed nothing' do
        attr(6).assumed_value.should == 'nothing'
      end

      it 'seventh attribute pattern is /this|that|something else/' do
        attr(7).pattern.should == '/this|that|something else/'
      end

      it 'seventh attribute assumed value is those' do
        attr(7).assumed_value.should == 'those'
      end

      it 'eighth attribute pattern is /cardio.*/' do
        attr(8).pattern.should == '/cardio.*/'
      end

      it 'eighth attribute assumed value is cardio.txt' do
        attr(8).assumed_value.should == 'cardio.txt'
      end

      it 'nineth attribute pattern is ^mg|mg/ml|mg/g^' do
        attr(9).pattern.should == '^mg|mg/ml|mg/g^'
      end

      it 'nineth attribute assumed value is mg' do
        attr(9).assumed_value.should == 'mg'
      end

      it 'tenth attribute list is apple, pear' do
        attr(10).list.should == ['apple','pear']
      end

      it 'tenth attribute assumed value is orange' do
        attr(10).assumed_value.should == 'orange'
      end
    end

    context 'Boolean constraint' do
      before(:all) do
        @constraints = const(1)
      end

      it 'first attribute is true valid' do
        attr(1).should be_true_valid
      end

      it 'first attribute is not false valid' do
        attr(1).should_not be_false_valid
      end

      it 'second attribute is not true valid' do
        attr(2).should_not be_true_valid
      end

      it 'second attribute is false valid' do
        attr(2).should be_false_valid
      end

      it 'third attribute is true valid' do
        attr(3).should be_true_valid
      end

      it 'third attrubute is false_valid' do
        attr(3).should be_false_valid
      end

      it 'fourth attribute is true valid' do
        attr(4).should be_true_valid
      end

      it 'fourth attribute is not false valid' do
        attr(4).should_not be_false_valid
      end

      it 'fourth attribute is asumed false' do
        attr(4).assumed_value.should be_false
      end

      it 'fifth attribute is not true valid' do
        attr(5).should_not be_true_valid
      end

      it 'fifth attribute is false valid' do
        attr(5).should be_false_valid
      end

      it 'fifth attribute is assumed true' do
        attr(5).assumed_value.should be_true
      end

      it 'sixth attribute is true valid' do
        attr(6).should be_true_valid
      end

      it 'sixth attribute is false valid' do
        attr(6).should be_false_valid
      end

      it 'sixth attribute is assumed true' do
        attr(6).assumed_value.should be_true
      end
    end
  end
end
