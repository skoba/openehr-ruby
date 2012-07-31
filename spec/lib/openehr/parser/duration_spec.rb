require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/parser_spec_helper'

# ticket 172

describe ADLParser do
  context 'CDuration type' do
    before(:all) do
      archetype = adl14_archetype('adl-test-entry.durations.test.adl')
      @attributes = archetype.definition.attributes
    end

    def attr(index)
      return @const.children[index-1].attributes[0].children[0]
    end

    context 'Duration without assumed value' do
      before(:all) do
        @const = @attributes[0].children[0].attributes[0]
      end

      context '1st attribute PT0s' do
        before(:all) do
          @at = attr(1)
        end

        it '1st item of the list is PT0s' do
          @at.list[0].value.should == 'PT0s'
        end

        it 'does not have assumed_value' do
          @at.should_not have_assumed_value
        end
      end

      context '2nd attribute P1d' do
        before(:all) do
          @at = attr(2)
        end

        it '1st item of the list is P1d' do
          @at.list[0].value.should == 'P1d'
        end

        it 'day is 1' do
          @at.list[0].days.should == 1
        end

        it 'months is 0' do
          @at.list[0].months.should be 0
        end

        it 'does not have assumed_value' do
          @at.should_not have_assumed_value
        end
      end

      context '3rd attribute PT2h5m0s' do
        before(:all) do
          @at = attr(3)
        end

        it '1st item of the list is PT2h5m0s' do
          @at.list[0].value.should == 'PT2h5m0s'
        end

        it 'hours should 2' do
          @at.list[0].hours.should be 2
        end
      end

      context '4th attribute |PT1h55m0s..PT2h5m0s|' do
        before(:all) do
          @at = attr(4)
        end

        it 'lower range is PT1h55m0s' do
          @at.range.lower.value.should == 'PT1h55m0s'
        end

        it 'upper range is PT2h5m0s' do
          @at.range.upper.value.should == 'PT2h5m0s'
        end

        it 'is upper included' do
          @at.range.should be_upper_included
        end

        it 'is lower included' do
          @at.range.should be_lower_included
        end
      end

      context '5th attribute |<=PT1h|' do
        before(:all) do
          @at = attr(5)
        end

        it 'upper range is PT1h' do
          @at.range.upper.value.should == 'PT1h'
        end

        it 'is upper included' do
          @at.range.should be_upper_included
        end

        it 'is lower unbounded' do
          @at.range.should be_lower_unbounded
        end
      end

      context '6th attribute P1DT1H2M3S' do
        before(:all) do
          @at = attr(6)
        end

        it '1st item of the list is P1DT1H2M3S' do
          @at.list[0].value.should == 'P1DT1H2M3S'
        end

        it 'day is 1' do
          @at.list[0].days.should == 1
        end

        it 'seconds is 3' do
          @at.list[0].seconds.should be 3
        end
      end

      context '7th attribute P1W2DT1H2M3S' do
        before(:all) do
          @at = attr(7)
        end

        it '1st item of the list is P1W2DT1H2M3S' do
          @at.list[0].value.should == 'P1W2DT1H2M3S'
        end

        it 'weeks is 1' do
          @at.list[0].weeks.should be 1
        end

        it 'minutes is 2' do
          @at.list[0].minutes.should be 2
        end
      end

      context '8th attribute P3M1W2DT1H2M3S' do
        before(:all) do
          @at = attr(8)
        end

        it '1st item of the list is P3M1W2DT1H2M3S' do
          @at.list[0].value.should == 'P3M1W2DT1H2M3S'
        end

        it 'months are 3' do
          @at.list[0].months.should be 3
        end

        it 'hours are 1' do
          @at.list[0].hours.should be 1
        end
      end

      context '9th attribute PDTH' do
        before(:all) do
          @at = attr(9)
        end

        it 'pattern is PDTH' do
          @at.pattern.should == 'PDTH'
        end
      end

      context '10th attribute |PT10M|' do
        before(:all) do
          @at = attr(10)
        end

        it 'upper range is PT10M' do
          @at.range.upper.value.should == 'PT10M'
        end

        it 'lower range is PT10M' do
          @at.range.lower.value.should == 'PT10M'
        end

        it 'lower range minutes are 10' do
          @at.range.lower.minutes.should be 10
        end

        it 'lower range months are 0' do
          @at.range.lower.months.should be 0
        end

        it 'is upper included' do
          @at.range.should be_upper_included
        end

        it 'is lower included' do
          @at.range.should be_lower_included
        end
      end

      context '11th attribute PYMWDTHMS' do
        before(:all) do
          @at = attr(11)
        end

        it 'pattern is PYMWDTHMS' do
          @at.pattern.should == 'PYMWDTHMS'
        end
      end

# at1011 is duplicated

      context '12th attribute |PT0.004s|' do
        before(:all) do
          @at = attr(12)
        end

        it 'upper range is PT0.004s' do
          @at.range.upper.value.should == 'PT0.004s'
        end

        it 'lower range is PT0.004s' do
          @at.range.lower.value.should == 'PT0.004s'
        end

        it 'lower range fractional second are 0.004' do
          @at.range.lower.fractional_second.should == 0.004
        end

        it 'lower range fractional second are 0.004' do
          @at.range.lower.fractional_second.should == 0.004
        end

        it 'is upper included' do
          @at.range.should be_upper_included
        end

        it 'is lower included' do
          @at.range.should be_lower_included
        end
      end

      context '13th attribute |PT10.01s|' do
        before(:all) do
          @at = attr(13)
        end

        it 'upper range is PT10.01s' do
          @at.range.upper.value.should == 'PT10.01s'
        end

        it 'lower range is PT10.01s' do
          @at.range.lower.value.should == 'PT10.01s'
        end

        it 'lower range seconds are 10' do
          @at.range.lower.seconds.should == 10
        end

        it 'lower range fractionsl second are 0.01' do
          @at.range.lower.fractional_second.should == 0.01
        end

        it 'is upper included' do
          @at.range.should be_upper_included
        end

        it 'is lower included' do
          @at.range.should be_lower_included
        end
      end

      context '14th attribute |PT1.1s|' do
        before(:all) do
          @at = attr(14)
        end

        it 'upper range is PT1.1s' do
          @at.range.upper.value.should == 'PT1.1s'
        end

        it 'lower range is PT1.1s' do
          @at.range.lower.value.should == 'PT1.1s'
        end

        it 'upper range seconds are 1' do
          @at.range.upper.seconds.should == 1
        end

        it 'upper range fractional second are 0.1' do
          @at.range.upper.fractional_second.should == 0.1
        end

        it 'is upper included' do
          @at.range.should be_upper_included
        end

        it 'is lower included' do
          @at.range.should be_lower_included
        end
      end

      context '15th attribute' do
        before(:all) do
          @at = attr(15)
        end

        it 'has PTMS pattern' do
          @at.pattern.should == 'PTMS'
        end

        it 'range is lower included' do
          @at.range.should be_lower_included
        end

        it 'lower range is PT0S' do
          @at.range.lower.value.should == 'PT0S'
        end

        it 'lower range second is 0' do
          @at.range.lower.seconds.should == 0
        end

        it 'is not upper included' do
          @at.range.should_not be_upper_included
        end
      end
    end

    context 'Duration with assumed value' do
      before(:all) do
        @const = @attributes[0].children[1].attributes[0]
      end

      context '1st attribute PT0s; P1d' do
        before(:all) do
          @at = attr(1)
        end

        it '1st item of the list is PT0s' do
          @at.list[0].value.should == 'PT0s'
        end

        it 'has assumed_value' do
          @at.should have_assumed_value
        end

        it 'assumed value is P1d' do
          @at.assumed_value.value.should == 'P1d'
        end
      end

      context '2nd attribute P1d; P1d' do
        before(:all) do
          @at = attr(2)
        end

        it '1st item of the list is P1d' do
          @at.list[0].value.should == 'P1d'
        end

        it 'day is 1' do
          @at.list[0].days.should == 1
        end

        it 'months is 0' do
          @at.list[0].months.should be 0
        end

        it 'assumed value is P1d' do
          @at.assumed_value.value.should == 'P1d'
        end
      end

      context '3rd attribute PT2h5m0s; P1d' do
        before(:all) do
          @at = attr(3)
        end

        it '1st item of the list is PT2h5m0s' do
          @at.list[0].value.should == 'PT2h5m0s'
        end

        it 'hours should 2' do
          @at.list[0].hours.should be 2
        end

        it 'assumed value is P1d' do
          @at.assumed_value.value.should == 'P1d'
        end
      end

      context '4th attribute |PT1h55m0s..PT2h5m0s|; P1d' do
        before(:all) do
          @at = attr(4)
        end

        it 'lower range is PT1h55m0s' do
          @at.range.lower.value.should == 'PT1h55m0s'
        end

        it 'upper range is PT2h5m0s' do
          @at.range.upper.value.should == 'PT2h5m0s'
        end

        it 'is upper included' do
          @at.range.should be_upper_included
        end

        it 'is lower included' do
          @at.range.should be_lower_included
        end

        it 'assumed value is P1d' do
          @at.assumed_value.value.should == 'P1d'
        end
      end

      context '5th attribute |<=PT1h|; P1d' do
        before(:all) do
          @at = attr(5)
        end

        it 'upper range is PT1h' do
          @at.range.upper.value.should == 'PT1h'
        end

        it 'is upper included' do
          @at.range.should be_upper_included
        end

        it 'is lower unbounded' do
          @at.range.should be_lower_unbounded
        end

        it 'assumed value is P1d' do
          @at.assumed_value.value.should == 'P1d'
        end
      end

      context '6th attribute PDTH; P1d' do
        before(:all) do
          @at = attr(6)
        end

        it 'pattern is PDTH' do
          @at.pattern.should == 'PDTH'
        end

        it 'assumed value is P1d' do
          @at.assumed_value.value.should == 'P1d'
        end
      end

# at1007 - at1009 was skiped

      context '7th attribute |PT10M|; PT12M' do
        before(:all) do
          @at = attr(7)
        end

        it 'upper range is PT10M' do
          @at.range.upper.value.should == 'PT10M'
        end

        it 'lower range is PT10M' do
          @at.range.lower.value.should == 'PT10M'
        end

        it 'lower range minutes are 10' do
          @at.range.lower.minutes.should be 10
        end

        it 'lower range months are 0' do
          @at.range.lower.months.should be 0
        end

        it 'is upper included' do
          @at.range.should be_upper_included
        end

        it 'is lower included' do
          @at.range.should be_lower_included
        end

        it 'assumed value is PT12M' do
          @at.assumed_value.value.should == 'PT12M'
        end

        it 'assumed value minutes is 12' do
          @at.assumed_value.minutes.should be 12
        end
      end
    end
  end
end
