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

        it 'does not have assumed_value' do
          @at.should_not have_assumed_value
        end
      end
    end
  end
end
