require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/parser_spec_helper'

# ticket 177

def attr(index)
  return @constraints[index-1].children[0]
end

def const(index)
  return @attributes[index].children[0].attributes
end


describe ADLParser do
  context 'Date Time type' do
    before(:all) do
      archetype = adl14_archetype('adl-test-entry.datetime.test.adl')
      @attributes = archetype.definition.attributes
    end

    context 'Date type' do
      before(:all) do
        @constraints = const(0)
      end

      context '1st attribute yyyy-mm-dd' do
        before(:all) do
          @at = attr(1)
        end

        it 'pattern is yyyy-mm-dd' do
          @at.pattern.should == 'yyyy-mm-dd'
        end

        it 'does not have assumed_value' do
          @at.should_not have_assumed_value
        end
      end

      context '2nd attribute yyyy-mm-dd' do
        before(:all) do
          @at = attr(2)
        end

        it 'pattern is yyyy-??-??' do
          @at.pattern.should == 'yyyy-??-??'
        end
      end

      context '3rd attribute yyyy-mm-??' do
        before(:all) do
          @at = attr(3)
        end

        it 'pattern is yyyy-mm-??' do
          @at.pattern.should == 'yyyy-mm-??'
        end
      end

      context '4th attribute yyyy-??-XX' do
        before(:all) do
          @at = attr(4)
        end

        it ' pattern is yyyy-??-XX' do
          @at.pattern.should == 'yyyy-??-XX'
        end
      end

      context '5th attribute 1983-12-25' do
        before(:all) do
          @at = attr(5)
        end

        it '1st item of list is 1983-12-25' do
          @at.list[0].value.should == '1983-12-25'
        end
      end

      context '5th attribute 1983-12-25' do
        before(:all) do
          @at = attr(5)
        end

        it '1st item of list is 1983-12-25' do
          @at.list[0].value.should == '1983-12-25'
        end
      end
 
      context '6th attribute 2000-01-01' do
        before(:all) do
          @at = attr(6)
        end

        it '1st item of list is 2000-01-01' do
          @at.list[0].value.should == '2000-01-01'
        end
      end

      context '6th attribute 2000-01-01' do
        before(:all) do
          @at = attr(6)
        end

        it '1st item of list is 2000-01-01' do
          @at.list[0].value.should == '2000-01-01'
        end
      end

      context '7th attribute |2004-09-20..2004-10-20|' do
        before(:all) do
          @at = attr(7)
        end

        it 'lower range is 2004-09-20' do
          @at.range.lower.value.should == '2004-09-20'
        end

        it 'upper range is 2004-10-20' do
          @at.range.upper.value.should == '2004-10-20'
        end

        it 'is lower included' do
          @at.range.should be_lower_included
        end

        it 'is upper included' do
          @at.range.should be_upper_included
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
      end

# data_attr 12 was skipped

      context '12th attribute yyyy-mm-dd; 2000-01-01' do
        before(:all) do
          @at = attr(12)
        end

        it 'pattern is yyyy-mm-dd' do
          @at.pattern.should == 'yyyy-mm-dd'
        end

        it 'has assumed_value' do
          @at.should have_assumed_value
        end

        it 'assumed value is 2000-01-01' do
          @at.assumed_value.value.should == '2000-01-01'
        end
      end

      context '13th attribute yyyy-mm-dd; 2001-01-01' do
        before(:all) do
          @at = attr(13)
        end

        it 'pattern is yyyy-??-??' do
          @at.pattern.should == 'yyyy-??-??'
        end

        it 'assumed value is 2001-01-01' do
          @at.assumed_value.value.should == '2001-01-01'
        end
      end

      context '14th attribute yyyy-mm-??' do
        before(:all) do
          @at = attr(14)
        end

        it 'pattern is yyyy-mm-??; 2002-01-01' do
          @at.pattern.should == 'yyyy-mm-??'
        end

        it 'assumed value is 2002-01-01' do
          @at.assumed_value.value.should == '2002-01-01'
        end
      end

      context '15th attribute yyyy-??-XX; 2003-01-01' do
        before(:all) do
          @at = attr(15)
        end

        it ' pattern is yyyy-??-XX' do
          @at.pattern.should == 'yyyy-??-XX'
        end

        it 'assumed value is 2003-01-01' do
          @at.assumed_value.value.should == '2003-01-01'
        end
      end

      context '16th attribute 1983-12-25; 2004-01-01' do
        before(:all) do
          @at = attr(16)
        end

        it '1st item of list is 1983-12-25' do
          @at.list[0].value.should == '1983-12-25'
        end

        it 'assumed value is 2004-01-01' do
          @at.assumed_value.value.should == '2004-01-01'
        end
      end

      context '17th attribute 2000-01-01; 2005-01-01' do
        before(:all) do
          @at = attr(17)
        end

        it '1st item of list is 2000-01-01' do
          @at.list[0].value.should == '2000-01-01'
        end

        it 'assumed value is 2005-01-01' do
          @at.assumed_value.value.should == '2005-01-01'
        end
      end

      context '18th attribute |2004-09-20..2004-10-20; 2004-09-30|' do
        before(:all) do
          @at = attr(18)
        end

        it 'lower range is 2004-09-20' do
          @at.range.lower.value.should == '2004-09-20'
        end

        it 'upper range is 2004-10-20' do
          @at.range.upper.value.should == '2004-10-20'
        end

        it 'is lower included' do
          @at.range.should be_lower_included
        end

        it 'is upper included' do
          @at.range.should be_upper_included
        end

        it 'assumed value is 2004-09-30' do
          @at.assumed_value.value.should == '2004-09-30'
        end
      end

      context '19th attribute |< 2004-09-20|; 2004-09-01' do
        before(:all) do
          @at = attr(19)
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

        it 'assumed value is 2004-09-01' do
          @at.assumed_value.value.should == '2004-09-01'
        end
      end

      context '20th attribute |<= 2004-09-20|; 2003-09-20' do
        before(:all) do
          @at = attr(20)
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

        it 'assumed value is 2003-09-20' do
          @at.assumed_value.value.should == '2003-09-20'
        end
      end

      context '21st attribute |> 2004-09-20|; 2005-01-02' do
        before(:all) do
          @at = attr(21)
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

        it 'assumed value is 2005-01-02' do
          @at.assumed_value.value.should == '2005-01-02'
        end
      end

      context '22nd attribute |>= 2004-09-20|; 2005-10-30' do
        before(:all) do
          @at = attr(22)
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

        it 'assumed value is 2005-10-30' do
          @at.assumed_value.value.should == '2005-10-30'
        end
      end

      context '23rd attribute |2004-09-20|' do
        before(:all) do
          @at = attr(23)
        end

        it 'lower range is 2004-09-20' do
          @at.range.lower.value.should == '2004-09-20'
        end

        it 'upper range is 2004-09-20' do
          @at.range.upper.value.should == '2004-09-20'
        end

        it 'is lower included' do
          @at.range.should be_lower_included
        end

        it 'is upper included' do
          @at.range.should be_upper_included
        end
      end
    end

    context 'Time type' do
      before(:all) do
        @constraints = const(1)
      end

      context '1st attribute hh:mm:ss' do
        before(:all) do
          @at = attr(1)
        end

        it 'pattern is hh:mm:ss' do
          @at.pattern.should == 'hh:mm:ss'
        end

        it 'does not have assumed_value' do
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
      end

      context '3rd attribute hh:??:XX' do
        before(:all) do
          @at = attr(3)
        end

        it 'pattern is hh:??:XX' do
          @at.pattern.should == 'hh:??:XX'
        end
      end

      context '4th attribute hh:??:??' do
        before(:all) do
          @at = attr(4)
        end

        it 'pattern is hh:??:??' do
          @at.pattern.should == 'hh:??:??'
        end
      end

      context '5th attribute 22:00:05' do
        before(:all) do
          @at = attr(5)
        end

        it '1st item of the list is 22:00:05' do
          @at.list[0].value.should == '22:00:05'
        end

        it 'does not have assumed_value' do
          @at.should_not have_assumed_value
        end
      end

      context '6th attribute 00:00:59' do
        before(:all) do
          @at = attr(6)
        end

        it '1st item of the list is 00:00:59' do
          @at.list[0].value.should == '00:00:59'
        end
      end

      context '7th attribute 12:35' do
        before(:all) do
          @at = attr(7)
        end

        it '1st item of the list is 12:35' do
          @at.list[0].value.should == '12:35'
        end
      end

      context '8th attribute 12:35:45,666' do
        before(:all) do
          @at = attr(8)
        end

        it '1st item of the list is 12:35:45,666' do
          @at.list[0].value.should == '12:35:45,666'
        end
      end

      context '8th attribute 12:35:45,666' do
        before(:all) do
          @at = attr(8)
        end

        it '1st item of the list is 12:35:45,666' do
          @at.list[0].value.should == '12:35:45,666'
        end
      end

      context '9th attribute 12:35:45-0700' do
        before(:all) do
          @at = attr(9)
        end

        it '1st item of the list is 12:35:45-0700' do
          @at.list[0].value.should == '12:35:45-0700'
        end

        it 'time zone is -0700' do
          @at.list[0].timezone.should == '-0700'
        end
      end

      context '10th attribute 12:35:45+0800' do
        before(:all) do
          @at = attr(10)
        end

        it '1st item of the list is 12:35:45+0800' do
          @at.list[0].value.should == '12:35:45+0800'
        end

        it 'time zone is +0800' do
          @at.list[0].timezone.should == '+0800'
        end
      end

      context '11th attribute 12:35:45,999-0700' do
        before(:all) do
          @at = attr(11)
        end

        it '1st item of the list is 12:35:45,999-0700' do
          @at.list[0].value.should == '12:35:45,999-0700'
        end

        it 'time zone is -0700' do
          @at.list[0].timezone.should == '-0700'
        end
      end

      context '12th attribute 12:35:45,000+0800' do
        before(:all) do
          @at = attr(12)
        end

        it '1st item of the list is 12:35:45,000+0800' do
          @at.list[0].value.should == '12:35:45,000+0800'
        end

        it 'time zone is +0800' do
          @at.list[0].timezone.should == '+0800'
        end

        it 'fractional second is 0' do
          @at.list[0].fractional_second == 0
        end
      end

      context '13th attribute 12:35:45,000Z' do
        before(:all) do
          @at = attr(13)
        end

        it '1st item of the list is 12:35:45,000Z' do
          @at.list[0].value.should == '12:35:45,000Z'
        end

        it 'time zone is +0800' do
          @at.list[0].timezone.should == 'Z'
        end

        it 'fractional second is 0' do
          @at.list[0].fractional_second == 0
        end
      end

      context '14th attribute 12:35:45,995-0700' do
        before(:all) do
          @at = attr(14)
        end

        it '1st item of the list is 12:35:45,995-0700' do
          @at.list[0].value.should == '12:35:45,995-0700'
        end

        it 'time zone is -0700' do
          @at.list[0].timezone.should == '-0700'
        end

        it 'fractional second is 995' do
          @at.list[0].fractional_second == 0.995
        end
      end

      context '15th attribute 12:35:45,001+0800' do
        before(:all) do
          @at = attr(15)
        end

        it '1st item of the list is 12:35:45,001+0800' do
          @at.list[0].value.should == '12:35:45,001+0800'
        end

        it 'time zone is -0700' do
          @at.list[0].timezone.should == '+0800'
        end

        it 'fractional second is 0.001' do
          @at.list[0].fractional_second == 0.001
        end
      end

      context '15th attribute 12:35:45,001+0800' do
        before(:all) do
          @at = attr(15)
        end

        it '1st item of the list is 12:35:45,001+0800' do
          @at.list[0].value.should == '12:35:45,001+0800'
        end

        it 'time zone is -0700' do
          @at.list[0].timezone.should == '+0800'
        end

        it 'fractional second is 0.001' do
          @at.list[0].fractional_second == 0.001
        end
      end

      context '16th attribute |12:35..16:35|' do
        before(:all) do
          @at = attr(16)
        end

        it 'lower range is 12:35' do
          @at.range.lower.value.should == '12:35'
        end

        it 'upper range is 12:35' do
          @at.range.upper.value.should == '16:35'
        end

        it 'is lower included' do
          @at.range.should be_lower_included
        end

        it 'is upper included' do
          @at.range.should be_upper_included
        end
      end

      context '17th attribute |< 12:35|' do
        before(:all) do
          @at = attr(17)
        end

        it 'upper range is 12:35' do
          @at.range.upper.value.should == '12:35'
        end

        it 'is lower unbounded' do
          @at.range.should be_lower_unbounded
        end

        it 'is not upper included' do
          @at.range.should_not be_upper_included
        end
      end

      context '18th attribute |<= 12:35|' do
        before(:all) do
          @at = attr(18)
        end

        it 'upper range is 12:35' do
          @at.range.upper.value.should == '12:35'
        end

        it 'is lower unbounded' do
          @at.range.should be_lower_unbounded
        end

        it 'is upper included' do
          @at.range.should be_upper_included
        end
      end

      context '19th attribute |> 12:35|' do
        before(:all) do
          @at = attr(19)
        end

        it 'lower range is 12:35' do
          @at.range.lower.value.should == '12:35'
        end

        it 'is upper unbounded' do
          @at.range.should be_upper_unbounded
        end

        it 'is not lower included' do
          @at.range.should_not be_upper_included
        end
      end

      context '19th attribute |> 12:35|' do
        before(:all) do
          @at = attr(19)
        end

        it 'lower range is 12:35' do
          @at.range.lower.value.should == '12:35'
        end

        it 'is upper unbounded' do
          @at.range.should be_upper_unbounded
        end

        it 'is not lower included' do
          @at.range.should_not be_lower_included
        end
      end

      context '20th attribute |>= 12:35|' do
        before(:all) do
          @at = attr(20)
        end

        it 'lower range is 12:35' do
          @at.range.lower.value.should == '12:35'
        end

        it 'is upper unbounded' do
          @at.range.should be_upper_unbounded
        end

        it 'is lower included' do
          @at.range.should be_lower_included
        end
      end

      context '21st attribute hh:mm:ss; 10:00:00' do
        before(:all) do
          @at = attr(21)
        end

        it 'pattern is hh:mm:ss' do
          @at.pattern.should == 'hh:mm:ss'
        end

        it 'has assumed_value' do
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

        it 'assumed value is 10:00:00' do
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

        it 'assumed value is 10:00:00' do
          @at.assumed_value.value.should == '10:00:00'
        end
      end

      context '25th attribute 22:00:05; 10:00:00' do
        before(:all) do
          @at = attr(25)
        end

        it '1st item of the list is 22:00:05' do
          @at.list[0].value.should == '22:00:05'
        end

        it 'have assumed_value' do
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

        it '1st item of the list is 00:00:59' do
          @at.list[0].value.should == '00:00:59'
        end

        it 'assumed value is 10:00:00' do
          @at.assumed_value.value.should == '10:00:00'
        end
      end

      context '27th attribute 12:35' do
        before(:all) do
          @at = attr(27)
        end

        it '1st item of the list is 12:35 10:00:00' do
          @at.list[0].value.should == '12:35'
        end

        it 'assumed value is 10:00:00' do
          @at.assumed_value.value.should == '10:00:00'
        end
      end

      context '28th attribute 12:35:45,666; 10:00:00' do
        before(:all) do
          @at = attr(28)
        end

        it '1st item of the list is 12:35:45,666' do
          @at.list[0].value.should == '12:35:45,666'
        end

        it 'assumed value is 10:00:00' do
          @at.assumed_value.value.should == '10:00:00'
        end
      end

      context '29th attribute 12:35:45-0700; 10:00:00' do
        before(:all) do
          @at = attr(29)
        end

        it '1st item of the list is 12:35:45-0700' do
          @at.list[0].value.should == '12:35:45-0700'
        end

        it 'time zone is -0700' do
          @at.list[0].timezone.should == '-0700'
        end

        it 'assumed value is 10:00:00' do
          @at.assumed_value.value.should == '10:00:00'
        end
      end

      context '30th attribute 12:35:45+0800; 10:00:00' do
        before(:all) do
          @at = attr(30)
        end

        it '1st item of the list is 12:35:45+0800' do
          @at.list[0].value.should == '12:35:45+0800'
        end

        it 'time zone is +0800' do
          @at.list[0].timezone.should == '+0800'
        end

        it 'assumed value is 10:00:00' do
          @at.assumed_value.value.should == '10:00:00'
        end
      end

      context '32th attribute 12:35:45,000+0800; 10:00:00' do
        before(:all) do
          @at = attr(32)
        end

        it '1st item of the list is 12:35:45,000+0800' do
          @at.list[0].value.should == '12:35:45,000+0800'
        end

        it 'time zone is +0800' do
          @at.list[0].timezone.should == '+0800'
        end

        it 'fractional second is 0' do
          @at.list[0].fractional_second == 0
        end

        it 'assumed value is 10:00:00' do
          @at.assumed_value.value.should == '10:00:00'
        end
      end

      context '33th attribute 12:35:45,000Z; 10:00:00' do
        before(:all) do
          @at = attr(33)
        end

        it '1st item of the list is 12:35:45,000Z' do
          @at.list[0].value.should == '12:35:45,000Z'
        end

        it 'time zone is +0800' do
          @at.list[0].timezone.should == 'Z'
        end

        it 'fractional second is 0' do
          @at.list[0].fractional_second == 0
        end

        it 'assumed value is 10:00:00' do
          @at.assumed_value.value.should == '10:00:00'
        end
      end

      context '34th attribute 12:35:45,995-0700; 10:00:00' do
        before(:all) do
          @at = attr(34)
        end

        it '1st item of the list is 12:35:45,995-0700' do
          @at.list[0].value.should == '12:35:45,995-0700'
        end

        it 'time zone is -0700' do
          @at.list[0].timezone.should == '-0700'
        end

        it 'fractional second is 995' do
          @at.list[0].fractional_second == 0.995
        end

        it 'assumed value is 10:00:00' do
          @at.assumed_value.value.should == '10:00:00'
        end
      end

      context '35th attribute 12:35:45,001+0800; 10:00:00' do
        before(:all) do
          @at = attr(35)
        end

        it '1st item of the list is 12:35:45,001+0800' do
          @at.list[0].value.should == '12:35:45,001+0800'
        end

        it 'time zone is -0700' do
          @at.list[0].timezone.should == '+0800'
        end

        it 'fractional second is 0.001' do
          @at.list[0].fractional_second == 0.001
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

        it 'upper range is 12:35' do
          @at.range.upper.value.should == '16:35'
        end

        it 'is lower included' do
          @at.range.should be_lower_included
        end

        it 'is upper included' do
          @at.range.should be_upper_included
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

        it 'is lower unbounded' do
          @at.range.should be_lower_unbounded
        end

        it 'is not upper included' do
          @at.range.should_not be_upper_included
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

        it 'is lower unbounded' do
          @at.range.should be_lower_unbounded
        end

        it 'is upper included' do
          @at.range.should be_upper_included
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

        it 'is upper unbounded' do
          @at.range.should be_upper_unbounded
        end

        it 'is not lower included' do
          @at.range.should_not be_upper_included
        end

        it 'assumed value is 10:00:00' do
          @at.assumed_value.value.should == '10:00:00'
        end
      end

      context '40th attribute |>= 12:35|; 10:00:00' do
        before(:all) do
          @at = attr(40)
        end

        it 'lower range is 12:35' do
          @at.range.lower.value.should == '12:35'
        end

        it 'is upper unbounded' do
          @at.range.should be_upper_unbounded
        end

        it 'is lower included' do
          @at.range.should be_lower_included
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
          @at.range.lower.value.should == '12:35'
        end

        it 'is upper included' do
          @at.range.should be_upper_included
        end

        it 'is lower included' do
          @at.range.should be_lower_included
        end

        it 'is not upper unbounded' do
          @at.range.should_not be_upper_unbounded
        end

        it 'is not lower unbounded' do
          @at.range.should_not be_lower_unbounded
        end
      end

      context '42nd attribute 00:00:59,0' do
        before(:all) do
          @at = attr(42)
        end

        it '1st item of the list is 00:00:59,0' do
          @at.list[0].value.should == '00:00:59,0'
        end
      end
    end

    context 'DateTime type' do
      before(:all) do
        @constraints = const(2)
      end

      context '1st attribute yyyy-mm-dd hh:mm:ss' do
        before(:all) do
          @at = attr(1)
        end

        it 'pattern is yyyy-mm-dd hh:mm:ss' do
          @at.pattern.should == 'yyyy-mm-dd hh:mm:ss'
        end

        it 'does not have assumed_value' do
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
      end

      context '3rd attribute yyyy-mm-dd hh:mm:XX' do
        before(:all) do
          @at = attr(3)
        end

        it 'pattern is yyyy-mm-dd hh:mm:XX' do
          @at.pattern.should == 'yyyy-mm-dd hh:mm:XX'
        end
      end

      context '4th attribute yyyy-mm-dd hh:??:XX' do
        before(:all) do
          @at = attr(4)
        end

        it 'pattern is yyyy-mm-dd hh:??:XX' do
          @at.pattern.should == 'yyyy-mm-dd hh:??:XX'
        end
      end

      context '5th attribute yyyy-??-?? ??:??:??' do
        before(:all) do
          @at = attr(5)
        end

        it 'pattern is yyyy-mm-dd hh:??:XX' do
          @at.pattern.should == 'yyyy-??-?? ??:??:??'
        end
      end

      context '6th attribute 1983-12-25T22:00:05' do
        before(:all) do
          @at = attr(6)
        end

        it '1st item of list is 1983-12-25T22:00:05' do
          @at.list[0].value.should == '1983-12-25T22:00:05'
        end
      end

      context '7th attribute 2000-01-01T00:00:59' do
        before(:all) do
          @at = attr(7)
        end

        it '1st item of list is 2000-01-01T00:00:59' do
          @at.list[0].value.should == '2000-01-01T00:00:59'
        end
      end

      context '7th attribute 2000-01-01T00:00:59' do
        before(:all) do
          @at = attr(7)
        end

        it '1st item of list is 2000-01-01T00:00:59' do
          @at.list[0].value.should == '2000-01-01T00:00:59'
        end
      end

      context '8th attribute 2000-01-01T00:00:59' do
        before(:all) do
          @at = attr(8)
        end

        it '1st item of list is 2000-01-01T00:00:59' do
          @at.list[0].value.should == '2000-01-01T00:00:59'
        end
      end

      context '9th attribute 2000-01-01T00:00:59,105' do
        before(:all) do
          @at = attr(9)
        end

        it '1st item of list is 2000-01-01T00:00:59,105' do
          @at.list[0].value.should == '2000-01-01T00:00:59,105'
        end

        it 'fractional second is 0.105' do
          @at.list[0].fractional_second.should == 0.105
        end
      end

      context '10th attribute 2000-01-01T00:00:59Z' do
        before(:all) do
          @at = attr(10)
        end

        it '1st item of list is 2000-01-01T00:00:59Z' do
          @at.list[0].value.should == '2000-01-01T00:00:59Z'
        end

        it 'timezone is Z' do
          @at.list[0].timezone.should == 'Z'
        end
      end


      context '11th attribute 2000-01-01T00:00:59+1200' do
        before(:all) do
          @at = attr(11)
        end

        it '1st item of list is 2000-01-01T00:00:59+1200' do
          @at.list[0].value.should == '2000-01-01T00:00:59+1200'
        end

        it 'timezone is +1200' do
          @at.list[0].timezone.should == '+1200'
        end
      end

      context '12th attribute 2000-01-01T00:00:59,500Z' do
        before(:all) do
          @at = attr(12)
        end

        it '1st item of list is 2000-01-01T00:00:59,500Z' do
          @at.list[0].value.should == '2000-01-01T00:00:59,500Z'
        end

        it 'fractional second is 0.500' do
          @at.list[0].fractional_second.should == 0.500
        end

        it 'timezone is Z' do
          @at.list[0].timezone.should == 'Z'
        end
      end

      context '13th attribute 2000-01-01T00:00:59,500+1200' do
        before(:all) do
          @at = attr(13)
        end

        it '1st item of list is 2000-01-01T00:00:59,500+1200' do
          @at.list[0].value.should == '2000-01-01T00:00:59,500+1200'
        end

        it 'fractional second is 0.500' do
          @at.list[0].fractional_second.should == 0.500
        end

        it 'timezone is Z' do
          @at.list[0].timezone.should == '+1200'
        end
      end

      context '13th attribute 2000-01-01T00:00:59,500+1200' do
        before(:all) do
          @at = attr(13)
        end

        it '1st item of list is 2000-01-01T00:00:59,500+1200' do
          @at.list[0].value.should == '2000-01-01T00:00:59,500+1200'
        end

        it 'fractional second is 0.500' do
          @at.list[0].fractional_second.should == 0.500
        end

        it 'timezone is +1200' do
          @at.list[0].timezone.should == '+1200'
        end
      end

      context '14th attribute 2000-01-01T00:00:59,000Z' do
        before(:all) do
          @at = attr(14)
        end

        it '1st item of list is 2000-01-01T00:00:59,000Z' do
          @at.list[0].value.should == '2000-01-01T00:00:59,000Z'
        end

        it 'fractional second is 0' do
          @at.list[0].fractional_second.should == 0
        end

        it 'timezone is Z' do
          @at.list[0].timezone.should == 'Z'
        end
      end

      context '15th attribute 2000-01-01T00:00:59,000+1200' do
        before(:all) do
          @at = attr(15)
        end

        it '1st item of list is 2000-01-01T00:00:59,000+1200' do
          @at.list[0].value.should == '2000-01-01T00:00:59,000+1200'
        end

        it 'fractional second is 0' do
          @at.list[0].fractional_second.should == 0
        end

        it 'timezone is +1200' do
          @at.list[0].timezone.should == '+1200'
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

        it 'is lower included' do
          @at.range.should be_lower_included
        end

        it 'is upper included' do
          @at.range.should be_upper_included
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
      end

      context '18th attribute |<= 2000-01-01T00:00:00|' do
        before(:all) do
          @at = attr(18)
        end

        it 'upper range is 2000-01-01T00:00:00' do
          @at.range.upper.value.should == '2000-01-01T00:00:00'
        end

        it 'is upper included' do
          @at.range.should be_upper_included
        end

        it 'is lower unbounded' do
          @at.range.should be_lower_unbounded
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
      end

      context '21st attribute yyyy-mm-dd hh:mm:ss; 2006-03-31T01:12:00' do
        before(:all) do
          @at = attr(21)
        end

        it 'pattern is yyyy-mm-dd hh:mm:ss' do
          @at.pattern.should == 'yyyy-mm-dd hh:mm:ss'
        end

        it 'has assumed_value' do
          @at.should have_assumed_value
        end

        it 'assumed value is 2006-03-31T01:12:00' do
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

        it 'assumed value is 2006-03-31T01:12:00' do
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

        it 'assumed value is 2006-03-31T01:12:00' do
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

        it 'assumed value is 2006-03-31T01:12:00' do
          @at.assumed_value.value.should == '2006-03-31T01:12:00'
        end
      end

      context '25th attribute yyyy-??-?? ??:??:??; 2006-03-31T01:12:00' do
        before(:all) do
          @at = attr(25)
        end

        it 'pattern is yyyy-mm-dd hh:??:XX' do
          @at.pattern.should == 'yyyy-??-?? ??:??:??'
        end

        it 'assumed value is 2006-03-31T01:12:00' do
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

        it 'assumed value is 2006-03-31T01:12:00' do
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

        it 'assumed value is 2006-03-31T01:12:00' do
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

        it 'assumed value is 2006-03-31T01:12:00' do
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

        it 'fractional second is 0.105' do
          @at.list[0].fractional_second.should == 0.105
        end

        it 'assumed value is 2006-03-31T01:12:00' do
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

        it 'timezone is Z' do
          @at.list[0].timezone.should == 'Z'
        end

        it 'assumed value is 2006-03-31T01:12:00' do
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

        it 'timezone is Z' do
          @at.list[0].timezone.should == '+1200'
        end

        it 'assumed value is 2006-03-31T01:12:00' do
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

        it 'fractional second is 0.500' do
          @at.list[0].fractional_second.should == 0.500
        end

        it 'timezone is Z' do
          @at.list[0].timezone.should == 'Z'
        end

        it 'assumed value is 2006-03-31T01:12:00' do
          @at.assumed_value.value.should == '2006-03-31T01:12:00'
        end
      end

      context '33th attribute 2000-01-01T00:00:59,500+1200; 2006-03-31T01:12:00' do
        before(:all) do
          @at = attr(33)
        end

        it '1st item of list is 2000-01-01T00:00:59,500+1200' do
          @at.list[0].value.should == '2000-01-01T00:00:59,500+1200'
        end

        it 'fractional second is 0.500' do
          @at.list[0].fractional_second.should == 0.500
        end

        it 'timezone is Z' do
          @at.list[0].timezone.should == '+1200'
        end

        it 'assumed value is 2006-03-31T01:12:00' do
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

        it 'fractional second is 0' do
          @at.list[0].fractional_second.should == 0
        end

        it 'timezone is Z' do
          @at.list[0].timezone.should == 'Z'
        end

        it 'assumed value is 2006-03-31T01:12:00' do
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

        it 'fractional second is 0' do
          @at.list[0].fractional_second.should == 0
        end

        it 'timezone is +1200' do
          @at.list[0].timezone.should == '+1200'
        end

        it 'assumed value is 2006-03-31T01:12:00' do
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

        it 'is lower included' do
          @at.range.should be_lower_included
        end

        it 'is upper included' do
          @at.range.should be_upper_included
        end

        it 'assumed value is 2006-03-31T01:12:00' do
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

        it 'assumed value is 2006-03-31T01:12:00' do
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

        it 'is upper included' do
          @at.range.should be_upper_included
        end

        it 'is lower unbounded' do
          @at.range.should be_lower_unbounded
        end

        it 'assumed value is 2006-03-31T01:12:00' do
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

        it 'assumed value is 2006-03-31T01:12:00' do
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

        it 'assumed value is 2006-03-31T01:12:00' do
          @at.assumed_value.value.should == '2006-03-31T01:12:00'
        end
      end

      context '41st attribute yyyy-??-??T??:??:??' do
        before(:all) do
          @at = attr(41)
        end

        it 'pattern is yyyy-??-??T??:??:??' do
          @at.pattern.should == 'yyyy-??-??T??:??:??'
        end

        it 'does not have assumed_value' do
          @at.should_not have_assumed_value
        end
      end

      context '42nd attribute |2000-01-01T00:00:00|' do
        before(:all) do
          @at = attr(42)
        end

        it 'lower range is 12:35' do
          @at.range.lower.value.should == '2000-01-01T00:00:00'
        end

        it 'upper range is 12:35' do
          @at.range.lower.value.should == '2000-01-01T00:00:00'
        end

        it 'is upper included' do
          @at.range.should be_upper_included
        end

        it 'is lower included' do
          @at.range.should be_lower_included
        end

        it 'is not upper unbounded' do
          @at.range.should_not be_upper_unbounded
        end

        it 'is not lower unbounded' do
          @at.range.should_not be_lower_unbounded
        end
      end

      context '43rd attribute 1995-03-17T12:01' do
        before(:all) do
          @at = attr(43)
        end

        it '1st item of list is 1995-03-17T12:01' do
          @at.list[0].value.should == '1995-03-17T12:01'
        end

        it 'hour is 12' do
          @at.list[0].hour.should be 12
        end

        it 'minute is 1' do
          @at.list[0].minute.should be 1
        end
      end

      context '44th attribute 1995-03-17T12' do
        before(:all) do
          @at = attr(43)
        end

        it '1st item of list is 1995-03-17T12:01' do
          @at.list[0].value.should == '1995-03-17T12:01'
        end

        it 'hour is 12' do
          @at.list[0].hour.should be 12
        end
      end
    end
  end
end
