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
  end
end
