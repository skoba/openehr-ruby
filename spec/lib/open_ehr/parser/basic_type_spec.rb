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

      it 'ninth attribute pattern is ^mg|mg/ml|mg/g^' do
        attr(9).pattern.should == '^mg|mg/ml|mg/g^'
      end

      it 'ninth attribute assumed value is mg' do
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

    context 'Integer constraint' do
      before(:all) do
        @constraints = const(2)
      end

      context 'first attribute' do
        it 'list is 55' do
          attr(1).list.should == [55]
        end

        it 'assumed value is nil' do
          attr(1).should_not have_assumed_value
        end
      end

      context 'second attribute' do
        it 'list is 10,20,30' do
          attr(2).list.should == [10,20,30]
        end

        it 'assumed value is nil' do
          attr(2).should_not have_assumed_value
        end
      end

      context 'third attribute' do
        it 'upper range is 100' do
          attr(3).range.upper.should be 100
        end

        it 'lower range is 0' do
          attr(3).range.lower.should be 0
        end

        it 'lower included' do
          attr(3).range.should be_lower_included
        end

        it 'upper included' do
          attr(3).range.should be_upper_included
        end

        it 'assumed_value is nil' do
          attr(3).should_not have_assumed_value
        end
      end

      context 'fourth attribute' do
        it 'lower range is 10' do
          attr(4).range.lower.should be 10
        end

        it 'is not lower included' do
          attr(4).range.should_not be_lower_included
        end

        it 'is upper unbounded' do
          attr(4).range.should be_upper_unbounded
        end

        it 'assumed value is nil' do
          attr(4).should_not have_assumed_value
        end
      end

      context 'fifth attribute' do
        it 'upper range is 10' do
          attr(5).range.upper.should be 10
        end

        it 'is not upper included' do
          attr(5).range.should_not be_upper_included
        end

        it 'is lower unbounded' do
          attr(5).range.should be_lower_unbounded
        end

        it 'assumed value is nil' do
          attr(5).should_not have_assumed_value
        end
      end

      context 'sixth attribute' do
        it 'lower range is 10' do
          attr(6).range.lower.should be 10
        end

        it 'is lower included' do
          attr(6).range.should be_lower_included
        end

        it 'is upper_unbounded' do
          attr(6).range.should be_upper_unbounded
        end

        it 'assumed value is nil' do
          attr(6).should_not have_assumed_value
        end
      end

      context 'seventh attribute' do
        it 'upper range is 10' do
          attr(7).range.upper.should be 10
        end

        it 'is upper included' do
          attr(7).range.should be_upper_included
        end

        it 'is lower unbounded' do
          attr(7).range.should be_lower_unbounded
        end

        it 'does not have assumed value' do
          attr(7).should_not have_assumed_value
        end
      end

      context 'eighth attribute' do
        it 'lower range is -10' do
          attr(8).range.lower.should be -10
        end

        it 'upper range is -5' do
          attr(8).range.upper.should be -5
        end

        it 'is lower included' do
          attr(8).range.should be_lower_included
        end

        it 'is upper included' do
          attr(8).range.should be_upper_included
        end

        it 'does not have assumed value' do
          attr(8).should_not have_assumed_value
        end
      end

# integer attr9 was passed

      context 'ninth attribute' do
        it 'list is 50' do
          attr(9).list.should == [55]
        end

        it 'has assumed value' do
          attr(9).should have_assumed_value
        end

        it 'assumed value is 50' do
          attr(9).assumed_value.should be 50
        end
      end

      context 'tenth attribute' do
        it 'list is 10,20,30' do
          attr(10).list.should == [10,20,30]
        end

        it 'assumed value is 20' do
          attr(10).assumed_value.should be 20
        end
      end

      context 'eleventh attribute' do
        it 'lower range is 0' do
          attr(11).range.lower.should be 0
        end

        it 'upper range is 100' do
          attr(11).range.upper.should be 100
        end

        it 'is lower included' do
          attr(11).range.should be_lower_included
        end

        it 'is upper included' do
          attr(11).range.should be_upper_included
        end

        it 'assumed value is 50' do
          attr(11).assumed_value.should be 50
        end
      end

      context 'twelfth attribute' do
        it 'lower range is 10' do
          attr(12).range.lower.should be 10
        end

        it 'is not lower included' do
          attr(12).range.should_not be_lower_included
        end

        it 'is upper unbounded' do
          attr(12).range.should be_upper_unbounded
        end

        it 'assumed value is 20' do
          attr(12).assumed_value.should be 20
        end
      end

      context 'thirteenth attribute' do
        it 'upper range is 10' do
          attr(13).range.upper.should be 10
        end

        it 'is not upper included' do
          attr(13).range.should_not be_upper_included
        end

        it 'is lower unbounded' do
          attr(13).range.should be_lower_unbounded
        end

        it 'assumed value is 5' do
          attr(13).assumed_value.should be 5
        end
      end

      context 'fourteenth attribute' do
        it 'lower range is 10' do
          attr(14).range.lower.should be 10
        end

        it 'is lower included' do
          attr(14).range.should be_lower_included
        end

        it 'is upper unbounded' do
          attr(14).range.should be_upper_unbounded
        end

        it 'assumed value is 12' do
          attr(14).assumed_value.should be 12
        end
      end

      context '15th attribute' do
        it 'upper range is 10' do
          attr(15).range.upper.should be 10
        end

        it 'is upper included' do
          attr(15).range.should be_upper_included
        end

        it 'is lower unbounded' do
          attr(15).range.should be_lower_unbounded
        end

        it 'assumed value is 8' do
          attr(15).assumed_value.should be 8
        end
      end

      context '16th attribute' do
        it 'lower range is -10' do
          attr(16).range.lower.should be -10
        end

        it 'upper range is -5' do
          attr(16).range.upper.should be -5
        end

        it 'is upper included' do
          attr(16).range.should be_upper_included
        end

        it 'is lower included' do
          attr(16).range.should be_lower_included
        end

        it 'assumed value is -7' do
          attr(16).assumed_value.should be -7
        end
      end

      context '17th attribute' do
        it 'upper range is 100' do
          attr(17).range.upper.should be 100
        end

        it 'lower range is 100' do
          attr(17).range.lower.should be 100
        end

        it 'is lower included' do
          attr(17).range.should be_lower_included
        end

        it 'is upper included' do
          attr(17).range.should be_upper_included
        end

        it 'does not have assumed value' do
          attr(17).should_not have_assumed_value
        end
      end

      context '18th attribute' do
        before(:all) do
          @attribute = attr(18)
        end

        it 'upper range is 100' do
          @attribute.range.upper.should be 100
        end

        it 'lower range is 0' do
          @attribute.range.lower.should be 0
        end

        it 'is not lower inlcuded' do
          @attribute.range.should_not be_lower_included
        end

        it 'is upper included' do
          @attribute.range.should be_upper_included
        end

        it 'does not have assumed value' do
          @attribute.should_not have_assumed_value
        end
      end

      context '19th attribute' do
        before(:all) do
          @attribute = attr(19)
        end

        it 'upper range is 100' do
          @attribute.range.upper.should be 100
        end

        it 'lower range is 0' do
          @attribute.range.lower.should be 0
        end

        it 'is lower included' do
          @attribute.range.should be_lower_included
        end

        it 'is not upper included' do
          @attribute.range.should_not be_upper_included
        end

        it 'does not have assumed value' do
          @attribute.should_not have_assumed_value
        end
      end

      context '20th attribute |>0..<100|' do
        before(:all) do
          @attribute = attr(20)
        end

        it 'upper range is 100' do
          @attribute.range.upper.should be 100
        end

        it 'lower range is 0' do
          @attribute.range.lower.should be 0
        end

        it 'is not lower included' do
          @attribute.range.should_not be_lower_included
        end

        it 'is not upper included' do
          @attribute.range.should_not be_upper_included
        end

        it 'does not have assumed value' do
          @attribute.should_not have_assumed_value
        end
      end
    end

    context 'Real constraint' do
      before(:all) do
        @constraints = const(3)
      end

      context '1st attribute' do
        before(:all) do
          @at = attr(1)
        end

        it 'list is 100.0' do
          @at.list.should == [100.0]
        end

        it 'assumed value is nil' do
          @at.should_not have_assumed_value
        end
      end

      context '2nd attribute' do
        before(:all) do
          @at = attr(2)
        end

        it 'list is 100.0' do
          @at.list.should == [10.0, 20.0, 30.0]
        end

        it 'assumed value is nil' do
          @at.should_not have_assumed_value
        end
      end

      context '3rd attribute' do
        before(:all) do
          @at = attr(3)
        end

        it 'lower range is 0.0' do
          @at.range.lower.should == 0.0
        end

        it 'upper range is 100.0' do
          @at.range.upper.should == 100.0
        end
        
        it 'assumed value is nil' do
          @at.should_not have_assumed_value
        end
      end

      context '4th attribute' do
        before(:all) do
          @at = attr(4)
        end

        it 'lower range is 10' do
          @at.range.lower.should == 10.0
        end

        it 'is not lower included' do
          @at.range.should_not be_lower_included
        end

        it 'is upper unbounded' do
          @at.range.should be_upper_unbounded
        end

        it 'assumed value is nil' do
          @at.should_not have_assumed_value
        end
      end

      context '5th attribute' do
        before(:all) do
          @at = attr(5)
        end

        it 'upper range is 10.0' do
          @at.range.upper.should == 10.0
        end

        it 'is not upper included' do
          @at.range.should_not be_upper_included
        end

        it 'is lower unbounded' do
          @at.range.should be_lower_unbounded
        end

        it 'assumed value is nil' do
          @at.should_not have_assumed_value
        end
      end

      context '6th attribute' do
        before(:all) do
          @at = attr(6)
        end

        it 'lower range is 10.0' do
          @at.range.lower.should == 10.0
        end

        it 'is lower included' do
          @at.range.should be_lower_included
        end

        it 'is upper_unbounded' do
          @at.range.should be_upper_unbounded
        end

        it 'assumed value is nil' do
          @at.should_not have_assumed_value
        end
      end

      context '7th attribute' do
        before(:all) do
          @at = attr(7)
        end

        it 'upper range is 10.0' do
          @at.range.upper.should ==10.0
        end

        it 'is upper included' do
          @at.range.should be_upper_included
        end

        it 'is lower unbounded' do
          @at.range.should be_lower_unbounded
        end

        it 'does not have assumed value' do
          @at.should_not have_assumed_value
        end
      end

      context '8th attribute' do
        before(:all) do
          @at = attr(8)
        end

        it 'lower range is -10.0' do
          @at.range.lower.should == -10.0
        end

        it 'upper range is -5.0' do
          @at.range.upper.should == -5.0
        end

        it 'is lower included' do
          @at.range.should be_lower_included
        end

        it 'is upper included' do
          @at.range.should be_upper_included
        end

        it 'does not have assumed value' do
          @at.should_not have_assumed_value
        end
      end

      context '9th attribute' do
        before(:all) do
          @at = attr(9)
        end

        it 'list is 100.0' do
          @at.list.should == [100.0]
        end

        it 'has assumed value' do
          @at.should have_assumed_value
        end

        it 'assumed value is 50' do
          @at.assumed_value.should == 80.0
        end
      end

      context '10th attribute' do
        before(:all) do
          @at = attr(10)
        end

        it 'list is 10.0,20.0,30.0' do
          @at.list.should == [10.0,20.0,30.0]
        end

        it 'assumed value is 20.0' do
          @at.assumed_value.should == 20.0
        end
      end

      context '11th attribute' do
        before(:all) do
          @at = attr(11)
        end

        it 'lower range is 0.0' do
          @at.range.lower.should == 0.0
        end

        it 'upper range is 100.0' do
          @at.range.upper.should == 100.0
        end

        it 'is lower included' do
          @at.range.should be_lower_included
        end

        it 'is upper included' do
          @at.range.should be_upper_included
        end

        it 'assumed value is 60.0' do
          @at.assumed_value.should == 60.0
        end
      end

      context '12th attribute' do
        before(:all) do
          @at = attr(12)
        end

        it 'lower range is 10.0' do
          @at.range.lower.should == 10.0
        end

        it 'is not lower included' do
          @at.range.should_not be_lower_included
        end

        it 'is upper unbounded' do
          @at.range.should be_upper_unbounded
        end

        it 'assumed value is 30.0' do
          @at.assumed_value.should == 30.0
        end
      end

      context '13th attribute' do
        before(:all) do
          @at = attr(13)
        end

        it 'upper range is 10.0' do
          @at.range.upper.should == 10
        end

        it 'is not upper included' do
          @at.range.should_not be_upper_included
        end

        it 'is lower unbounded' do
          @at.range.should be_lower_unbounded
        end

        it 'assumed value is 2.0' do
          @at.assumed_value.should == 2.0
        end
      end

      context '14th attribute' do
        before(:all) do
          @at = attr(14)
        end

        it 'lower range is 10.0' do
          @at.range.lower.should == 10.0
        end

        it 'is lower included' do
          @at.range.should be_lower_included
        end

        it 'is upper unbounded' do
          @at.range.should be_upper_unbounded
        end

        it 'assumed value is 10.0' do
          @at.assumed_value.should == 10.0
        end
      end

      context '15th attribute' do
        before(:all) do
          @at = attr(15)
        end

        it 'upper range is 10.0' do
          @at.range.upper.should == 10.0
        end

        it 'is upper included' do
          @at.range.should be_upper_included
        end

        it 'is lower unbounded' do
          @at.range.should be_lower_unbounded
        end

        it 'assumed value is 9.0' do
          @at.assumed_value.should == 9.0
        end
      end

      context '16th attribute' do
        before(:all) do
          @at = attr(16)
        end

        it 'lower range is -10.0' do
          @at.range.lower.should == -10.0
        end

        it 'upper range is -5.0' do
          @at.range.upper.should == -5.0
        end

        it 'is upper included' do
          @at.range.should be_upper_included
        end

        it 'is lower included' do
          @at.range.should be_lower_included
        end

        it 'assumed value is -8.0' do
          @at.assumed_value.should == -8.0
        end
      end

      context '17th attribute' do
        before(:all) do
          @at = attr(17)
        end

        it 'upper range is 100.0' do
          @at.range.upper.should == 100.0
        end

        it 'lower range is 100.0' do
          @at.range.lower.should == 100.0
        end

        it 'is lower included' do
          @at.range.should be_lower_included
        end

        it 'is upper included' do
          @at.range.should be_upper_included
        end

        it 'does not have assumed value' do
          @at.should_not have_assumed_value
        end
      end

      context '18th attribute' do
        before(:all) do
          @attribute = attr(18)
        end

        it 'upper range is 100' do
          @attribute.range.upper.should == 100.0
        end

        it 'lower range is 0' do
          @attribute.range.lower.should == 0.0
        end

        it 'is not lower inlcuded' do
          @attribute.range.should_not be_lower_included
        end

        it 'is upper included' do
          @attribute.range.should be_upper_included
        end

        it 'does not have assumed value' do
          @attribute.should_not have_assumed_value
        end
      end

      context '19th attribute' do
        before(:all) do
          @attribute = attr(19)
        end

        it 'upper range is 100.0' do
          @attribute.range.upper.should == 100.0
        end

        it 'lower range is 0.0' do
          @attribute.range.lower.should == 0.0
        end

        it 'is lower included' do
          @attribute.range.should be_lower_included
        end

        it 'is not upper included' do
          @attribute.range.should_not be_upper_included
        end

        it 'does not have assumed value' do
          @attribute.should_not have_assumed_value
        end
      end

      context '20th attribute |>0..<100|' do
        before(:all) do
          @attribute = attr(20)
        end

        it 'upper range is 100.0' do
          @attribute.range.upper.should == 100.0
        end

        it 'lower range is 0.0' do
          @attribute.range.lower.should == 0.0
        end

        it 'is not lower included' do
          @attribute.range.should_not be_lower_included
        end

        it 'is not upper included' do
          @attribute.range.should_not be_upper_included
        end

        it 'does not have assumed value' do
          @attribute.should_not have_assumed_value
        end
      end
    end

    context 'Date constraint' do
      before(:all) do
        @constraints = const(4)
      end

      context '1st attribute yyyy-mm-dd' do
        before(:all) do
          @at = attr(1)
        end

        it 'pattern is yyyy-mm-dd' do
          @at.pattern.should == 'yyyy-mm-dd'
        end

        it 'does not have assumed value' do
          @at.should_not have_assumed_value
        end
      end

      context '2nd attribute yyyy-??-??' do
        before(:all) do
          @at = attr(2)
        end

        it 'pattern is yyyy-??-' do
          @at.pattern.should == 'yyyy-??-??'
        end

        it 'does not have assumed value' do
          @at.should_not have_assumed_value
        end
      end

      context '3rd attribute yyyy-mm-??' do
        before(:all) do
          @at = attr(3)
        end

        it 'pattern is yyyy-mm-??' do
          @at.pattern.should == 'yyyy-mm-??'
        end

        it 'does not have assumed value' do
          @at.should_not have_assumed_value
        end
      end

      context '4th attribute yyyy-??-XX' do
        before(:all) do
          @at = attr(4)
        end

        it 'pattern is yyyy-??-XX' do
          @at.pattern.should == 'yyyy-??-XX'
        end

        it 'does not have assumed value' do
          @at.should_not have_assumed_value
        end
      end

      context '5th attribute 1983-12-25' do
        before(:all) do
          @at = attr(5)
        end

        it 'a first item of list is 1983-12-25' do
          @at.list[0].value.should == '1983-12-25'
        end

        it 'does not have assumed value' do
          @at.should_not have_assumed_value
        end
      end

      context '6th attribute 2000-01-01' do
        before(:all) do
          @at = attr(6)
        end

        it 'a first item of list is 2000-01-01' do
          @at.list[0].value.should == '2000-01-01'
        end

        it 'does not have assumed value' do
          @at.should_not have_assumed_value
        end
      end

      context '7th attribute |2004-09-20..2004-10-20|' do
        before(:all) do
          @at = attr(7)
        end

        it 'lower range is 2004-09-20' do
          @at.range.lower.value.should == '2004-09-20'
        end

        it 'is lower included' do
          @at.range.should be_lower_included
        end

        it 'upper range is 2004-10-20' do
          @at.range.upper.value.should == '2004-10-20'
        end

        it 'is upper included' do
          @at.range.should be_upper_included
        end

        it 'does not have assumed value' do
          @at.should_not have_assumed_value
        end
      end

      context '8th attribute |< 2004-09-20|' do
        before(:all) do
          @at = attr(8)
        end

        it 'upper range is 2004-09-20' do
          @at.range.upper.value.should == '2004-09-20'
        end

        it 'is not upper included' do
          @at.range.should_not be_upper_included
        end

        it 'is lower unbounded' do
          @at.range.should be_lower_unbounded
        end

        it 'does not have assumed value' do
          @at.should_not have_assumed_value
        end
      end

      context '9th attribute |<= 2004-09-20|' do
        before(:all) do
          @at = attr(9)
        end

        it 'upper range is 2004-09-20' do
          @at.range.upper.value.should == '2004-09-20'
        end

        it 'is upper included' do
          @at.range.should be_upper_included
        end

        it 'is lower unbounded' do
          @at.range.should be_lower_unbounded
        end

        it 'does not have assumed value' do
          @at.should_not have_assumed_value
        end
      end

      context '10th attribute |> 2004-09-20|' do
        before(:all) do
          @at = attr(10)
        end

        it 'lower range is 2004-09-20' do
          @at.range.lower.value.should == '2004-09-20'
        end

        it 'is not lower included' do
          @at.range.should_not be_lower_included
        end

        it 'is upper unbounded' do
          @at.range.should be_upper_unbounded
        end

        it 'does not have assumed value' do
          @at.should_not have_assumed_value
        end
      end

      context '11th attribute |>= 2004-09-20|' do
        before(:all) do
          @at = attr(11)
        end

        it 'lower range is 2004-09-20' do
          @at.range.lower.value.should == '2004-09-20'
        end

        it 'is lower included' do
          @at.range.should be_lower_included
        end

        it 'is upper unbounded' do
          @at.range.should be_upper_unbounded
        end

        it 'does not have assumed value' do
          @at.should_not have_assumed_value
        end
      end

      context '12th attribute |2001-12-25, ...|' do
        before(:all) do
          @at = attr(12)
        end

        it '1st item of list is 2001-12-25' do
          @at.list[0].value.should == '2001-12-25'
        end

        it 'does not have assumed value' do
          @at.should_not have_assumed_value
        end
      end
      
      context '13th attribute yyyy-mm-dd; 2000-01-01' do
        before(:all) do
          @at = attr(13)
        end

        it 'pattern is yy-mm-dd' do
          @at.pattern.should == 'yyyy-mm-dd'
        end

        it 'have assumed value' do
          @at.should have_assumed_value
        end

        it 'assumed value is 2000-01-01' do
          @at.assumed_value.value.should == '2000-01-01'
        end
      end
      
      context '14th attribute yyyy-??-??; 2001-01-01' do
        before(:all) do
          @at = attr(14)
        end

        it 'pattern is yy-mm-dd' do
          @at.pattern.should == 'yyyy-??-??'
        end

        it 'have assumed value' do
          @at.should have_assumed_value
        end

        it 'assumed value is 2001-01-01' do
          @at.assumed_value.value.should == '2001-01-01'
        end
      end
      
      context '15th attribute yyyy-mm-??; 2002-01-01' do
        before(:all) do
          @at = attr(15)
        end

        it 'pattern is yyyy-mm-dd' do
          @at.pattern.should == 'yyyy-mm-??'
        end

        it 'have assumed value' do
          @at.should have_assumed_value
        end

        it 'assumed value is 2002-01-01' do
          @at.assumed_value.value.should == '2002-01-01'
        end
      end

      context '16th attribute yyyy-??-XX; 2003-01-01' do
        before(:all) do
          @at = attr(16)
        end

        it 'pattern is yyyy-??-XX' do
          @at.pattern.should == 'yyyy-??-XX'
        end

        it 'have assumed value' do
          @at.should have_assumed_value
        end

        it 'assumed value is 2003-01-01' do
          @at.assumed_value.value.should == '2003-01-01'
        end
      end

      context '17th attribute 1983-12-25; 2004-01-01' do
        before(:all) do
          @at = attr(17)
        end

        it '1st item of list is 1983-12-25' do
          @at.list[0].value.should == '1983-12-25'
        end

        it 'have assumed value' do
          @at.should have_assumed_value
        end

        it 'assumed value is 2004-01-01' do
          @at.assumed_value.value.should == '2004-01-01'
        end
      end

      context '18th attribute 2000-01-01; 2005-01-01' do
        before(:all) do
          @at = attr(18)
        end

        it '1st item of list is 2000-01-01' do
          @at.list[0].value.should == '2000-01-01'
        end

        it 'have assumed value' do
          @at.should have_assumed_value
        end

        it 'assumed value is 2005-01-01' do
          @at.assumed_value.value.should == '2005-01-01'
        end
      end

      context '19th attribute |2004-09-20..2004-10-20|; 2004-09-30' do
        before(:all) do
          @at = attr(19)
        end

        it 'lower range is 2004-09-20' do
          @at.range.lower.value.should == '2004-09-20'
        end

        it 'is lower included' do
          @at.range.should be_lower_included
        end

        it 'upper range is 2004-10-20' do
          @at.range.upper.value.should == '2004-10-20'
        end

        it 'is upper included' do
          @at.range.should be_upper_included
        end

        it 'have assumed value' do
          @at.should have_assumed_value
        end

        it 'assumed value is 2004-09-30' do
          @at.assumed_value.value.should == '2004-09-30'
        end
      end

      context '20th attribute |< 2004-09-20|; 2004-09-01' do
        before(:all) do
          @at = attr(20)
        end

        it 'upper range is 2004-09-20' do
          @at.range.upper.value.should == '2004-09-20'
        end

        it 'is not upper included' do
          @at.range.should_not be_upper_included
        end

        it 'is lower unbounded' do
          @at.range.should be_lower_unbounded
        end

        it 'have assumed value' do
          @at.should have_assumed_value
        end

        it 'assumed_value is 2004-09-01' do
          @at.assumed_value.value.should == '2004-09-01'
        end
      end

      context '21st attribute |<= 2004-09-20|; 2003-09-20' do
        before(:all) do
          @at = attr(21)
        end

        it 'upper range is 2004-09-20' do
          @at.range.upper.value.should == '2004-09-20'
        end

        it 'is upper included' do
          @at.range.should be_upper_included
        end

        it 'is lower unbounded' do
          @at.range.should be_lower_unbounded
        end

        it 'have assumed value' do
          @at.should have_assumed_value
        end

        it 'assumed_value is 2003-09-20' do
          @at.assumed_value.value.should == '2003-09-20'
        end
      end

      context '22nd attribute |> 2004-09-20|; 2005-01-02' do
        before(:all) do
          @at = attr(22)
        end

        it 'lower range is 2004-09-20' do
          @at.range.lower.value.should == '2004-09-20'
        end

        it 'is not lower included' do
          @at.range.should_not be_lower_included
        end

        it 'is upper unbounded' do
          @at.range.should be_upper_unbounded
        end

        it 'have assumed value' do
          @at.should have_assumed_value
        end

        it 'assumed_value is 2005-01-02' do
          @at.assumed_value.value.should == '2005-01-02'
        end
      end

      context '23rd attribute |>= 2004-09-20|; 2005-10-30' do
        before(:all) do
          @at = attr(23)
        end

        it 'lower range is 2004-09-20' do
          @at.range.lower.value.should == '2004-09-20'
        end

        it 'is lower included' do
          @at.range.should be_lower_included
        end

        it 'is upper unbounded' do
          @at.range.should be_upper_unbounded
        end

        it 'have assumed value' do
          @at.should have_assumed_value
        end

        it 'assumed_value is 2005-10-30' do
          @at.assumed_value.value.should == '2005-10-30'
        end
      end

      context '24th attribute |2004-09-20|' do
        before(:all) do
          @at = attr(24)
        end

        it 'lower range is 2004-09-20' do
          @at.range.lower.value.should == '2004-09-20'
        end

        it 'is lower included' do
          @at.range.should be_lower_included
        end

        it 'upper range is 2004-09-20' do
          @at.range.upper.value.should == '2004-09-20'
        end

        it 'is upper included' do
          @at.range.should be_upper_included
        end

        it 'does not have assumed value' do
          @at.should_not have_assumed_value
        end
      end

      context '25th attribute 1995-03' do
        before(:all) do
          @at = attr(25)
        end

        it '1st item of list is 1995-03' do
          @at.list[0].value.should == '1995-03'
        end

        it 'does not have assumed value' do
          @at.should_not have_assumed_value
        end
      end
    end

    context 'Time constraint' do
      before(:all) do
        @constraints = const(5)
      end

      context '1st attribute hh:mm:ss' do
        before(:all) do
          @at = attr(1)
        end

        it 'pattern is hh:mm:ss' do
          @at.pattern.should == 'hh:mm:ss'
        end

        it 'does not have assumed value' do
          @at.should_not have_assumed_value
        end
      end

      context '2nd attribute hh:mm:XX' do
        before(:all) do
          @at = attr(2)
        end

        it 'pattern is hh:mm:XX' do
          @at.pattern.should == 'hh:mm:XX'
        end

        it 'does not have assumed value' do
          @at.should_not have_assumed_value
        end
      end

      context '3rd attribute hh:??:XX' do
        before(:all) do
          @at = attr(3)
        end

        it 'pattern is hh:??:XX' do
          @at.pattern.should == 'hh:??:XX'
        end

        it 'does not have assumed value' do
          @at.should_not have_assumed_value
        end
      end

      context '4th attribute hh:??:??' do
        before(:all) do
          @at = attr(4)
        end

        it 'pattern is hh:??:??' do
          @at.pattern.should == 'hh:??:??'
        end

        it 'does not have assumed value' do
          @at.should_not have_assumed_value
        end
      end

      context '5th attribute 22:00:05' do
        before(:all) do
          @at = attr(5)
        end

        it 'the 1st item of list is 22:00:05' do
          @at.list[0].value.should == '22:00:05'
        end

        it 'does not have assumed value' do
          @at.should_not have_assumed_value
        end
      end

      context '6th attribute 00:00:59' do
        before(:all) do
          @at = attr(6)
        end

        it 'the 1st item of list is 00:00:59' do
          @at.list[0].value.should == '00:00:59'
        end

        it 'does not have assumed value' do
          @at.should_not have_assumed_value
        end
      end

      context '7th attribute 12:35' do
        before(:all) do
          @at = attr(7)
        end

        it 'the 1st item of list is 12:35' do
          @at.list[0].value.should == '12:35'
        end

        it 'does not have assumed value' do
          @at.should_not have_assumed_value
        end
      end

      context '8th attribute 12:35:45,666' do
        before(:all) do
          @at = attr(8)
        end

        it 'the 1st item of list is 12:35:45,666' do
          @at.list[0].value.should == '12:35:45,666'
        end

        it 'does not have assumed value' do
          @at.should_not have_assumed_value
        end
      end

      context '9th attribute 12:35:45-0700' do
        before(:all) do
          @at = attr(9)
        end

        it 'the 1st item of list is 12:35:45-0700' do
          @at.list[0].value.should == '12:35:45-0700'
        end

        it 'does not have assumed value' do
          @at.should_not have_assumed_value
        end
      end

      context '10th attribute 12:35:45+0800' do
        before(:all) do
          @at = attr(10)
        end

        it 'the 1st item of list is 12:35:45+0800' do
          @at.list[0].value.should == '12:35:45+0800'
        end

        it 'does not have assumed value' do
          @at.should_not have_assumed_value
        end
      end

      context '11th attribute 12:35:45,999-0700' do
        before(:all) do
          @at = attr(11)
        end

        it 'the 1st item of list is 12:35:45,999-0700' do
          @at.list[0].value.should == '12:35:45,999-0700'
        end

        it 'does not have assumed value' do
          @at.should_not have_assumed_value
        end
      end

      context '12th attribute 12:35:45,000+0000' do
        before(:all) do
          @at = attr(12)
        end

        it 'the 1st item of list is 12:35:45,000+0800' do
          @at.list[0].value.should == '12:35:45,000+0800'
        end

        it 'does not have assumed value' do
          @at.should_not have_assumed_value
        end
      end

      context '13th attribute 12:35:45,000Z' do
        before(:all) do
          @at = attr(13)
        end

        it 'the 1st item of list is 12:35:45,000Z' do
          @at.list[0].value.should == '12:35:45,000Z'
        end

        it 'does not have assumed value' do
          @at.should_not have_assumed_value
        end
      end

      context '14th attribute 12:35:45,995-0700' do
        before(:all) do
          @at = attr(14)
        end

        it 'the 1st item of list is 12:35:45,995-0700' do
          @at.list[0].value.should == '12:35:45,995-0700'
        end

        it 'does not have assumed value' do
          @at.should_not have_assumed_value
        end
      end

      context '15th attribute 12:35:45,001+0800' do
        before(:all) do
          @at = attr(15)
        end

        it 'the 1st item of list is 12:35:45,001+0800' do
          @at.list[0].value.should == '12:35:45,001+0800'
        end

        it 'does not have assumed value' do
          @at.should_not have_assumed_value
        end
      end

      context '16th attribute |12:35..16:35|' do
        before(:all) do
          @at = attr(16)
        end

        it 'lower range is 12:35' do
          @at.range.lower.value.should == '12:35'
        end

        it 'upper range is 16:35' do
          @at.range.upper.value.should == '16:35'
        end

        it 'does not have assumed value' do
          @at.should_not have_assumed_value
        end
      end

      context '17th attribute |< 12:35|' do
        before(:all) do
          @at = attr(17)
        end

        it 'upper range is 12:35' do
          @at.range.upper.value.should == '12:35'
        end

        it 'is not upper included' do
          @at.range.should_not be_upper_included
        end

        it 'is lower unbounded' do
          @at.range.should be_lower_unbounded
        end

        it 'does not have assumed value' do
          @at.should_not have_assumed_value
        end
      end

      context '18th attribute |<= 12:35|' do
        before(:all) do
          @at = attr(18)
        end

        it 'upper range is 12:35' do
          @at.range.upper.value.should == '12:35'
        end

        it 'is upper included' do
          @at.range.should be_upper_included
        end

        it 'is lower unbounded' do
          @at.range.should be_lower_unbounded
        end

        it 'does not have assumed value' do
          @at.should_not have_assumed_value
        end
      end

      context '19th attribute |> 12:35|' do
        before(:all) do
          @at = attr(19)
        end

        it 'lower range is 12:35' do
          @at.range.lower.value.should == '12:35'
        end

        it 'is not lower included' do
          @at.range.should_not be_lower_included
        end

        it 'is upper unbounded' do
          @at.range.should be_upper_unbounded
        end

        it 'does not have assumed value' do
          @at.should_not have_assumed_value
        end
      end

      context '20th attribute |>= 12:35|' do
        before(:all) do
          @at = attr(20)
        end

        it 'lower range is 12:35' do
          @at.range.lower.value.should == '12:35'
        end

        it 'is lower included' do
          @at.range.should be_lower_included
        end

        it 'is upper unbounded' do
          @at.range.should be_upper_unbounded
        end

        it 'does not have assumed value' do
          @at.should_not have_assumed_value
        end
      end

      context '21st attribute hh:mm:ss; 10:00:00' do
        before(:all) do
          @at = attr(21)
        end

        it 'pattern is hh:mm:ss' do
          @at.pattern.should == 'hh:mm:ss'
        end

        it 'has assumed value' do
          @at.should have_assumed_value
        end

        it 'assumed value is 10:00:00' do
          @at.assumed_value.value.should == '10:00:00'
        end
      end

      context '22nd attribute hh:mm:XX; 10:00:00' do
        before(:all) do
          @at = attr(22)
        end

        it 'pattern is hh:mm:XX' do
          @at.pattern.should == 'hh:mm:XX'
        end

        it 'has assumed value' do
          @at.should have_assumed_value
        end

        it 'assumed value is 10:00:00' do
          @at.assumed_value.value.should == '10:00:00'
        end
      end

      context '23rd attribute hh:??:XX; 10:00:00' do
        before(:all) do
          @at = attr(23)
        end

        it 'pattern is hh:??:XX' do
          @at.pattern.should == 'hh:??:XX'
        end

        it 'has assumed value' do
          @at.should have_assumed_value
        end

        it 'assumed value is 10:00:00; 10:00:00' do
          @at.assumed_value.value.should == '10:00:00'
        end
      end

      context '24th attribute hh:??:??; 10:00:00' do
        before(:all) do
          @at = attr(24)
        end

        it 'pattern is hh:??:??' do
          @at.pattern.should == 'hh:??:??'
        end

        it 'has assumed value' do
          @at.should have_assumed_value
        end

        it 'assumed value is 10:00:00' do
          @at.assumed_value.value.should == '10:00:00'
        end
      end

      context '25th attribute 22:00:05; 10:00:00' do
        before(:all) do
          @at = attr(25)
        end

        it 'the 1st item of list is 22:00:05' do
          @at.list[0].value.should == '22:00:05'
        end

        it 'has assumed value' do
          @at.should have_assumed_value
        end

        it 'assumed value is 10:00:00' do
          @at.assumed_value.value.should == '10:00:00'
        end
      end

      context '26th attribute 00:00:59; 10:00:00' do
        before(:all) do
          @at = attr(26)
        end

        it 'the 1st item of list is 00:00:59' do
          @at.list[0].value.should == '00:00:59'
        end

        it 'has assumed value' do
          @at.should have_assumed_value
        end

        it 'assumed value is 10:00:00' do
          @at.assumed_value.value.should == '10:00:00'
        end
      end

      context '27th attribute 12:35; 10:00:00' do
        before(:all) do
          @at = attr(27)
        end

        it 'the 1st item of list is 12:35' do
          @at.list[0].value.should == '12:35'
        end

        it 'has assumed value' do
          @at.should have_assumed_value
        end

        it 'assumed value is 10:00:00' do
          @at.assumed_value.value.should == '10:00:00'
        end
      end

      context '28th attribute 12:35:45,666; 10:00:00' do
        before(:all) do
          @at = attr(28)
        end

        it 'the 1st item of list is 12:35:45,666' do
          @at.list[0].value.should == '12:35:45,666'
        end

        it 'has assumed value' do
          @at.should have_assumed_value
        end

        it 'assumed value is 10:00:00' do
          @at.assumed_value.value.should == '10:00:00'
        end
      end

      context '29th attribute 12:35:45-0700; 10:00:00' do
        before(:all) do
          @at = attr(29)
        end

        it 'the 1st item of list is 12:35:45-0700' do
          @at.list[0].value.should == '12:35:45-0700'
        end

        it 'has assumed value' do
          @at.should have_assumed_value
        end

        it 'assumed value is 10:00:00' do
          @at.assumed_value.value.should == '10:00:00'
        end
      end

      context '30th attribute 12:35:45+0800; 10:00:00' do
        before(:all) do
          @at = attr(30)
        end

        it 'the 1st item of list is 12:35:45+0800' do
          @at.list[0].value.should == '12:35:45+0800'
        end

        it 'has assumed value' do
          @at.should have_assumed_value
        end

        it 'assumed value is 10:00:00' do
          @at.assumed_value.value.should == '10:00:00'
        end
      end

      context '31st attribute 12:35:45,999-0700; 10:00:00' do
        before(:all) do
          @at = attr(31)
        end

        it 'the 1st item of list is 12:35:45,999-0700' do
          @at.list[0].value.should == '12:35:45,999-0700'
        end

        it 'has assumed value' do
          @at.should have_assumed_value
        end

        it 'assumed value is 10:00:00' do
          @at.assumed_value.value.should == '10:00:00'
        end
      end

      context '32nd attribute 12:35:45,000+0000; 10:00:00' do
        before(:all) do
          @at = attr(32)
        end

        it 'the 1st item of list is 12:35:45,000+0800' do
          @at.list[0].value.should == '12:35:45,000+0800'
        end

        it 'has assumed value' do
          @at.should have_assumed_value
        end

        it 'assumed value is 10:00:00' do
          @at.assumed_value.value.should == '10:00:00'
        end
      end

      context '33rd attribute 12:35:45,000Z; 10:00:00' do
        before(:all) do
          @at = attr(33)
        end

        it 'the 1st item of list is 12:35:45,000Z' do
          @at.list[0].value.should == '12:35:45,000Z'
        end

        it 'has assumed value' do
          @at.should have_assumed_value
        end

        it 'assumed value is 10:00:00' do
          @at.assumed_value.value.should == '10:00:00'
        end
      end

      context '34th attribute 12:35:45,995-0700; 10:00:00' do
        before(:all) do
          @at = attr(34)
        end

        it 'the 1st item of list is 12:35:45,995-0700' do
          @at.list[0].value.should == '12:35:45,995-0700'
        end

        it 'has assumed value' do
          @at.should have_assumed_value
        end

        it 'assumed value is 10:00:00' do
          @at.assumed_value.value.should == '10:00:00'
        end
      end

      context '35th attribute 12:35:45,001+0800; 10:00:00' do
        before(:all) do
          @at = attr(35)
        end

        it 'the 1st item of list is 12:35:45,001+0800' do
          @at.list[0].value.should == '12:35:45,001+0800'
        end

        it 'has assumed value' do
          @at.should have_assumed_value
        end

        it 'assumed value is 10:00:00' do
          @at.assumed_value.value.should == '10:00:00'
        end
      end

      context '36th attribute |12:35..16:35|; 10:00:00' do
        before(:all) do
          @at = attr(36)
        end

        it 'lower range is 12:35' do
          @at.range.lower.value.should == '12:35'
        end

        it 'upper range is 16:35' do
          @at.range.upper.value.should == '16:35'
        end

        it 'has assumed value' do
          @at.should have_assumed_value
        end

        it 'assumed value is 10:00:00' do
          @at.assumed_value.value.should == '10:00:00'
        end
      end

      context '37th attribute |< 12:35|; 10:00:00' do
        before(:all) do
          @at = attr(37)
        end

        it 'upper range is 12:35' do
          @at.range.upper.value.should == '12:35'
        end

        it 'is not upper included' do
          @at.range.should_not be_upper_included
        end

        it 'is lower unbounded' do
          @at.range.should be_lower_unbounded
        end

        it 'has assumed value' do
          @at.should have_assumed_value
        end

        it 'assumed value is 10:00:00' do
          @at.assumed_value.value.should == '10:00:00'
        end
      end

      context '38th attribute |<= 12:35|; 10:00:00' do
        before(:all) do
          @at = attr(38)
        end

        it 'upper range is 12:35' do
          @at.range.upper.value.should == '12:35'
        end

        it 'is upper included' do
          @at.range.should be_upper_included
        end

        it 'is lower unbounded' do
          @at.range.should be_lower_unbounded
        end

        it 'has assumed value' do
          @at.should have_assumed_value
        end

        it 'assumed value is 10:00:00' do
          @at.assumed_value.value.should == '10:00:00'
        end
      end

      context '39th attribute |> 12:35|; 10:00:00' do
        before(:all) do
          @at = attr(39)
        end

        it 'lower range is 12:35' do
          @at.range.lower.value.should == '12:35'
        end

        it 'is not lower included' do
          @at.range.should_not be_lower_included
        end

        it 'is upper unbounded' do
          @at.range.should be_upper_unbounded
        end

        it 'has assumed value' do
          @at.should have_assumed_value
        end

        it 'assumed value is 10:00:00' do
          @at.assumed_value.value.should == '10:00:00'
        end
      end

      context '40th attribute |>= 12:35; 10:00:00|' do
        before(:all) do
          @at = attr(40)
        end

        it 'lower range is 12:35' do
          @at.range.lower.value.should == '12:35'
        end

        it 'is lower included' do
          @at.range.should be_lower_included
        end

        it 'is upper unbounded' do
          @at.range.should be_upper_unbounded
        end

        it 'has assumed value' do
          @at.should have_assumed_value
        end

        it 'assumed value is 10:00:00' do
          @at.assumed_value.value.should == '10:00:00'
        end
      end

      context '41st attribute |12:35|' do
        before(:all) do
          @at = attr(41)
        end

        it 'lower range is 12:35' do
          @at.range.lower.value.should == '12:35'
        end

        it 'upper range is 12:35' do
          @at.range.upper.value.should == '12:35'
        end

        it 'is lower included' do
          @at.range.should be_lower_included
        end

        it 'is upper included' do
          @at.range.should be_upper_included
        end

        it 'does not have assumed value' do
          @at.should_not have_assumed_value
        end
      end

      context '42nd attribute 00:00:59,0' do
        before(:all) do
          @at = attr(42)
        end

        it 'the 1st item of list is 00:00:59,0' do
          @at.list[0].value.should == '00:00:59,0'
        end

        it 'does not have assumed value' do
          @at.should_not have_assumed_value
        end
      end
    end

    context 'DateTime constraint' do
      before(:all) do
        @constraints = const(6)
      end

      context '1st attribute yyyy-mm-dd hh:mm:ss' do
        before(:all) do
          @at = attr(1)
        end

        it 'pattern is yyyy-mm-dd hh:mm:ss' do
          @at.pattern.should == 'yyyy-mm-dd hh:mm:ss'
        end

        it 'does not have assumed value' do
          @at.should_not have_assumed_value
        end
      end

      context '2nd attribute yyyy-mm-dd hh:mm:??' do
        before(:all) do
          @at = attr(2)
        end

        it 'pattern is yyyy-mm-dd hh:mm:??' do
          @at.pattern.should == 'yyyy-mm-dd hh:mm:??'
        end

        it 'does not have assumed value' do
          @at.should_not have_assumed_value
        end
      end
      
      context '3rd attribute yyyy-mm-dd hh:mm:XX' do
        before(:all) do
          @at = attr(3)
        end

        it 'pattern is yyyy-mm-dd hh:mm:XX' do
          @at.pattern.should == 'yyyy-mm-dd hh:mm:XX'
        end

        it 'does not have assumed value' do
          @at.should_not have_assumed_value
        end
      end
      
      context '4th attribute yyyy-mm-dd hh:??:XX' do
        before(:all) do
          @at = attr(4)
        end

        it 'pattern is yyyy-mm-dd hh:??:XX' do
          @at.pattern.should == 'yyyy-mm-dd hh:??:XX'
        end

        it 'does not have assumed value' do
          @at.should_not have_assumed_value
        end
      end

      context '5th attribute yyyy-??-?? ??:??:??' do
        before(:all) do
          @at = attr(5)
        end

        it 'pattern is yyyy-??-?? ??:??:??' do
          @at.pattern.should == 'yyyy-??-?? ??:??:??'
        end

        it 'does not have assumed value' do
          @at.should_not have_assumed_value
        end
      end

      context '6th attribute 1983-12-25T22:00:05' do
        before(:all) do
          @at = attr(6)
        end

        it '1st item of list is 1983-12-25T22:00:05' do
          @at.list[0].value.should == '1983-12-25T22:00:05'
        end

        it 'does not have assumed value' do
          @at.should_not have_assumed_value
        end
      end

      context '7th attribute 2000-01-01T00:00:59' do
        before(:all) do
          @at = attr(7)
        end

        it '1st item of list is 2000-01-01T00:00:59' do
          @at.list[0].value.should == '2000-01-01T00:00:59'
        end

        it 'does not have assumed value' do
          @at.should_not have_assumed_value
        end
      end

      context '8th attribute 2000-01-01T00:00:59' do
        before(:all) do
          @at = attr(8)
        end

        it '1st item of list is 2000-01-01T00:00:59' do
          @at.list[0].value.should == '2000-01-01T00:00:59'
        end

        it 'does not have assumed value' do
          @at.should_not have_assumed_value
        end
      end

      context '9th attribute 2000-01-01T00:00:59,105' do
        before(:all) do
          @at = attr(9)
        end

        it '1st item of list is 2000-01-01T00:00:59,105' do
          @at.list[0].value.should == '2000-01-01T00:00:59,105'
        end

        it 'does not have assumed value' do
          @at.should_not have_assumed_value
        end
      end

      context '10th attribute 2000-01-01T00:00:59Z' do
        before(:all) do
          @at = attr(10)
        end

        it '1st item of list is 2000-01-01T00:00:59Z' do
          @at.list[0].value.should == '2000-01-01T00:00:59Z'
        end

        it 'does not have assumed value' do
          @at.should_not have_assumed_value
        end
      end

      context '11th attribute 2000-01-01T00:00:59+1200' do
        before(:all) do
          @at = attr(11)
        end

        it '1st item of list is 2000-01-01T00:00:59+1200' do
          @at.list[0].value.should == '2000-01-01T00:00:59+1200'
        end

        it 'does not have assumed value' do
          @at.should_not have_assumed_value
        end
      end

      context '12th attribute 2000-01-01T00:00:59,500Z' do
        before(:all) do
          @at = attr(12)
        end

        it '1st item of list is 2000-01-01T00:00:59,500Z' do
          @at.list[0].value.should == '2000-01-01T00:00:59,500Z'
        end

        it 'does not have assumed value' do
          @at.should_not have_assumed_value
        end
      end

      context '13th attribute 2000-01-01T00:00:59,500+1200' do
        before(:all) do
          @at = attr(13)
        end

        it '1st item of list is 2000-01-01T00:00:59,500+1200' do
          @at.list[0].value.should == '2000-01-01T00:00:59,500+1200'
        end

        it 'does not have assumed value' do
          @at.should_not have_assumed_value
        end
      end

      context '14th attribute 2000-01-01T00:00:59,000Z' do
        before(:all) do
          @at = attr(14)
        end

        it '1st item of list is 2000-01-01T00:00:59,000Z' do
          @at.list[0].value.should == '2000-01-01T00:00:59,000Z'
        end

        it 'does not have assumed value' do
          @at.should_not have_assumed_value
        end
      end

      context '15th attribute 2000-01-01T00:00:59,000+1200' do
        before(:all) do
          @at = attr(15)
        end

        it '1st item of list is 2000-01-01T00:00:59,000+1200' do
          @at.list[0].value.should == '2000-01-01T00:00:59,000+1200'
        end

        it 'does not have assumed value' do
          @at.should_not have_assumed_value
        end
      end

      context '16th attribute |2000-01-01T00:00:00..2000-01-02T00:00:00|' do
        before(:all) do
          @at = attr(16)
        end

        it 'lower range is 2000-01-01T00:00:00' do
          @at.range.lower.value.should == '2000-01-01T00:00:00'
        end

        it 'upper range is 2000-01-02T00:00:00' do
          @at.range.upper.value.should == '2000-01-02T00:00:00'
        end

        it 'is upper included' do
          @at.range.should be_upper_included
        end

        it 'is upper included' do
          @at.range.should be_upper_included
        end

        it 'does not have assumed value' do
          @at.should_not have_assumed_value
        end
      end

      context '17th attribute |< 2000-01-01T00:00:00|' do
        before(:all) do
          @at = attr(17)
        end

        it 'upper range is 2000-01-01T00:00:00' do
          @at.range.upper.value.should == '2000-01-01T00:00:00'
        end

        it 'is not upper included' do
          @at.range.should_not be_upper_included
        end

        it 'is lower unbounded' do
          @at.range.should be_lower_unbounded
        end

        it 'does not have assumed value' do
          @at.should_not have_assumed_value
        end
      end

      context '18th attribute |<= 2000-01-01T00:00:00|' do
        before(:all) do
          @at = attr(18)
        end

        it 'upper range is 2000-01-01T00:00:00' do
          @at.range.upper.value.should == '2000-01-01T00:00:00'
        end

        it 'is not upper included' do
          @at.range.should be_upper_included
        end

        it 'is lower unbounded' do
          @at.range.should be_lower_unbounded
        end

        it 'does not have assumed value' do
          @at.should_not have_assumed_value
        end
      end

      context '19th attribute |> 2000-01-01T00:00:00|' do
        before(:all) do
          @at = attr(19)
        end

        it 'lower range is 2000-01-01T00:00:00' do
          @at.range.lower.value.should == '2000-01-01T00:00:00'
        end

        it 'is not lower included' do
          @at.range.should_not be_lower_included
        end

        it 'is upper unbounded' do
          @at.range.should be_upper_unbounded
        end

        it 'does not have assumed value' do
          @at.should_not have_assumed_value
        end
      end

      context '20th attribute |>= 2000-01-01T00:00:00|' do
        before(:all) do
          @at = attr(20)
        end

        it 'lower range is 2000-01-01T00:00:00' do
          @at.range.lower.value.should == '2000-01-01T00:00:00'
        end

        it 'is lower included' do
          @at.range.should be_lower_included
        end

        it 'is upper unbounded' do
          @at.range.should be_upper_unbounded
        end

        it 'does not have assumed value' do
          @at.should_not have_assumed_value
        end
      end

      context '21st attribute yyyy-mm-dd hh:mm:ss; 2006-03-31T01:12:00|' do
        before(:all) do
          @at = attr(21)
        end

        it 'pattern is yyyy-mm-dd hh:mm:ss' do
          @at.pattern.should == 'yyyy-mm-dd hh:mm:ss'
        end

        it 'has assumed value' do
          @at.should have_assumed_value
        end

        it 'asssumed value is 2006-03-31T01:12:00' do
          @at.assumed_value.value.should == '2006-03-31T01:12:00'
        end
      end

      context '22nd attribute yyyy-mm-dd hh:mm:??; 2006-03-31T01:12:00' do
        before(:all) do
          @at = attr(22)
        end

        it 'pattern is yyyy-mm-dd hh:mm:??' do
          @at.pattern.should == 'yyyy-mm-dd hh:mm:??'
        end

        it 'asssumed value is 2006-03-31T01:12:00' do
          @at.assumed_value.value.should == '2006-03-31T01:12:00'
        end
      end

      context '23rd attribute yyyy-mm-dd hh:mm:XX; 2006-03-31T01:12:00' do
        before(:all) do
          @at = attr(23)
        end

        it 'pattern is yyyy-mm-dd hh:mm:XX' do
          @at.pattern.should == 'yyyy-mm-dd hh:mm:XX'
        end

        it 'asssumed value is 2006-03-31T01:12:00' do
          @at.assumed_value.value.should == '2006-03-31T01:12:00'
        end
      end

      context '24th attribute yyyy-mm-dd hh:??:XX; 2006-03-31T01:12:00' do
        before(:all) do
          @at = attr(24)
        end

        it 'pattern is yyyy-mm-dd hh:??:XX' do
          @at.pattern.should == 'yyyy-mm-dd hh:??:XX'
        end

        it 'asssumed value is 2006-03-31T01:12:00' do
          @at.assumed_value.value.should == '2006-03-31T01:12:00'
        end
      end

      context '25th attribute yyyy-??-?? ??:??:??; 2006-03-31T01:12:00' do
        before(:all) do
          @at = attr(25)
        end

        it 'pattern is yyyy-??-?? ??:??:??' do
          @at.pattern.should == 'yyyy-??-?? ??:??:??'
        end

        it 'asssumed value is 2006-03-31T01:12:00' do
          @at.assumed_value.value.should == '2006-03-31T01:12:00'
        end
      end

      context '26th attribute 1983-12-25T22:00:05; 2006-03-31T01:12:00' do
        before(:all) do
          @at = attr(26)
        end

        it '1st item of list is 1983-12-25T22:00:05' do
          @at.list[0].value.should == '1983-12-25T22:00:05'
        end

        it 'asssumed value is 2006-03-31T01:12:00' do
          @at.assumed_value.value.should == '2006-03-31T01:12:00'
        end
      end

      context '27th attribute 2000-01-01T00:00:59; 2006-03-31T01:12:00' do
        before(:all) do
          @at = attr(27)
        end

        it '1st item of list is 2000-01-01T00:00:59' do
          @at.list[0].value.should == '2000-01-01T00:00:59'
        end

        it 'asssumed value is 2006-03-31T01:12:00' do
          @at.assumed_value.value.should == '2006-03-31T01:12:00'
        end
      end

      context '28th attribute 2000-01-01T00:00:59,000; 2006-03-31T01:12:00' do
        before(:all) do
          @at = attr(28)
        end

        it '1st item of list is 2000-01-01T00:00:59,000' do
          @at.list[0].value.should == '2000-01-01T00:00:59,000'
        end

        it 'asssumed value is 2006-03-31T01:12:00' do
          @at.assumed_value.value.should == '2006-03-31T01:12:00'
        end
      end

      context '29th attribute 2000-01-01T00:00:59,105; 2006-03-31T01:12:00' do
        before(:all) do
          @at = attr(29)
        end

        it '1st item of list is 2000-01-01T00:00:59,105' do
          @at.list[0].value.should == '2000-01-01T00:00:59,105'
        end

        it 'asssumed value is 2006-03-31T01:12:00' do
          @at.assumed_value.value.should == '2006-03-31T01:12:00'
        end
      end

      context '30th attribute 2000-01-01T00:00:59Z; 2006-03-31T01:12:00' do
        before(:all) do
          @at = attr(30)
        end

        it '1st item of list is 2000-01-01T00:00:59Z' do
          @at.list[0].value.should == '2000-01-01T00:00:59Z'
        end

        it 'asssumed value is 2006-03-31T01:12:00' do
          @at.assumed_value.value.should == '2006-03-31T01:12:00'
        end
      end

      context '31st attribute 2000-01-01T00:00:59+1200; 2006-03-31T01:12:00' do
        before(:all) do
          @at = attr(31)
        end

        it '1st item of list is 2000-01-01T00:00:59+1200' do
          @at.list[0].value.should == '2000-01-01T00:00:59+1200'
        end

        it 'asssumed value is 2006-03-31T01:12:00' do
          @at.assumed_value.value.should == '2006-03-31T01:12:00'
        end
      end

      context '32nd attribute 2000-01-01T00:00:59,500Z; 2006-03-31T01:12:00' do
        before(:all) do
          @at = attr(32)
        end

        it '1st item of list is 2000-01-01T00:00:59,500Z' do
          @at.list[0].value.should == '2000-01-01T00:00:59,500Z'
        end

        it 'asssumed value is 2006-03-31T01:12:00' do
          @at.assumed_value.value.should == '2006-03-31T01:12:00'
        end
      end

      context '33rd attribute 2000-01-01T00:00:59,500+1200; 2006-03-31T01:12:00' do
        before(:all) do
          @at = attr(33)
        end

        it '1st item of list is 2000-01-01T00:00:59,500+1200' do
          @at.list[0].value.should == '2000-01-01T00:00:59,500+1200'
        end

        it 'asssumed value is 2006-03-31T01:12:00' do
          @at.assumed_value.value.should == '2006-03-31T01:12:00'
        end
      end

      context '34th attribute 2000-01-01T00:00:59,000Z; 2006-03-31T01:12:00' do
        before(:all) do
          @at = attr(34)
        end

        it '1st item of list is 2000-01-01T00:00:59,000Z' do
          @at.list[0].value.should == '2000-01-01T00:00:59,000Z'
        end

        it 'asssumed value is 2006-03-31T01:12:00' do
          @at.assumed_value.value.should == '2006-03-31T01:12:00'
        end
      end

      context '35th attribute 2000-01-01T00:00:59,000+1200; 2006-03-31T01:12:00' do
        before(:all) do
          @at = attr(35)
        end

        it '1st item of list is 2000-01-01T00:00:59,000+1200' do
          @at.list[0].value.should == '2000-01-01T00:00:59,000+1200'
        end

        it 'asssumed value is 2006-03-31T01:12:00' do
          @at.assumed_value.value.should == '2006-03-31T01:12:00'
        end
      end

      context '36th attribute |2000-01-01T00:00:00..2000-01-02T00:00:00|; 2006-03-31T01:12:00' do
        before(:all) do
          @at = attr(36)
        end

        it 'lower range is 2000-01-01T00:00:00' do
          @at.range.lower.value.should == '2000-01-01T00:00:00'
        end

        it 'upper range is 2000-01-02T00:00:00' do
          @at.range.upper.value.should == '2000-01-02T00:00:00'
        end

        it 'asssumed value is 2006-03-31T01:12:00' do
          @at.assumed_value.value.should == '2006-03-31T01:12:00'
        end
      end

      context '37th attribute |< 2000-01-01T00:00:00|; 2006-03-31T01:12:00' do
        before(:all) do
          @at = attr(37)
        end

        it 'upper range is 2000-01-01T00:00:00' do
          @at.range.upper.value.should == '2000-01-01T00:00:00'
        end

        it 'is not upper included' do
          @at.range.should_not be_upper_included
        end

        it 'is lower unbounded' do
          @at.range.should be_lower_unbounded
        end

        it 'asssumed value is 2006-03-31T01:12:00' do
          @at.assumed_value.value.should == '2006-03-31T01:12:00'
        end
      end

      context '38th attribute |<= 2000-01-01T00:00:00|; 2006-03-31T01:12:00' do
        before(:all) do
          @at = attr(38)
        end

        it 'upper range is 2000-01-01T00:00:00' do
          @at.range.upper.value.should == '2000-01-01T00:00:00'
        end

        it 'is not upper included' do
          @at.range.should be_upper_included
        end

        it 'is lower unbounded' do
          @at.range.should be_lower_unbounded
        end

        it 'asssumed value is 2006-03-31T01:12:00' do
          @at.assumed_value.value.should == '2006-03-31T01:12:00'
        end
      end

      context '39th attribute |> 2000-01-01T00:00:00|; 2006-03-31T01:12:00' do
        before(:all) do
          @at = attr(39)
        end

        it 'lower range is 2000-01-01T00:00:00' do
          @at.range.lower.value.should == '2000-01-01T00:00:00'
        end

        it 'is not lower included' do
          @at.range.should_not be_lower_included
        end

        it 'is upper unbounded' do
          @at.range.should be_upper_unbounded
        end

        it 'asssumed value is 2006-03-31T01:12:00' do
          @at.assumed_value.value.should == '2006-03-31T01:12:00'
        end
      end

      context '40th attribute |>= 2000-01-01T00:00:00|; 2006-03-31T01:12:00' do
        before(:all) do
          @at = attr(40)
        end

        it 'lower range is 2000-01-01T00:00:00' do
          @at.range.lower.value.should == '2000-01-01T00:00:00'
        end

        it 'is lower included' do
          @at.range.should be_lower_included
        end

        it 'is upper unbounded' do
          @at.range.should be_upper_unbounded
        end

        it 'asssumed value is 2006-03-31T01:12:00' do
          @at.assumed_value.value.should == '2006-03-31T01:12:00'
        end
      end

      context '41th attribute yyyy-??-??T??:??:??' do
        before(:all) do
          @at = attr(41)
        end

        it 'pattern is yyyy-??-??T??:??:??' do
          @at.pattern.should == 'yyyy-??-??T??:??:??'
        end
      end

      context '42th attribute |2000-01-01T00:00:00|' do
        before(:all) do
          @at = attr(36)
        end

        it 'lower range is 2000-01-01T00:00:00' do
          @at.range.lower.value.should == '2000-01-01T00:00:00'
        end

        it 'upper range is 2000-01-02T00:00:00' do
          @at.range.upper.value.should == '2000-01-02T00:00:00'
        end

        it 'is upper included' do
          @at.range.should be_upper_included
        end

        it 'is upper included' do
          @at.range.should be_upper_included
        end
      end
    end
  end
end
