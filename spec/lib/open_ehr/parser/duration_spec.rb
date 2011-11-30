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

    context 'Duration' do
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
    end
  end
end
