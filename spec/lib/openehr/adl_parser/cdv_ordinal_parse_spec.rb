require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/parser_spec_helper'
require 'openehr/am/openehr_profile/data_types/quantity'
include OpenEHR::AM::OpenEHRProfile::DataTypes::Quantity

describe ADLParser do
  describe CDvOrdinal do
    before(:all) do
      archetype = adl14_archetype('adl-test-entry.c_dv_ordinal.test.adl')
      @attributes = archetype.definition.attributes
    end

    def attr(index)
      return @attributes[0].children[0].attributes[0].children[index-1].attributes[0].children[0]
    end

    context '1st ordinals' do
      before(:all) do
        @at = attr(1)
      end

      it 'is an instance of CDvOrdinal' do
        expect(@at).to be_an_instance_of CDvOrdinal
      end

      context '1st item' do
        before(:all) do
          @item = @at.list[0]
        end

        it 'value is 0' do
          expect(@item.value).to be 0
        end

        it 'symbol value is local::at0003.0]' do
          expect(@item.symbol.value).to eq('[local::at0003.0]')
        end

        it 'defining code terminology is local' do
          expect(@item.symbol.defining_code.terminology_id.value).to eq('local')
        end

        it 'defining code string is at0003.0' do
          expect(@item.symbol.defining_code.code_string).to eq('at0003.0')
        end
      end

      context '2nd item' do
        before(:all) do
          @item = @at.list[1]
        end

        it 'value is 1' do
          expect(@item.value).to be 1
        end

        it 'symbol value is local::at0003.1' do
          expect(@item.symbol.value).to eq('[local::at0003.1]')
        end
      end

      context '3nd item' do
        before(:all) do
          @item = @at.list[2]
        end

        it 'value is 2' do
          expect(@item.value).to be 2
        end

        it 'symbol value is local::at0003.2' do
          expect(@item.symbol.value).to eq('[local::at0003.2]')
        end
      end

      context '4th item' do
        before(:all) do
          @item = @at.list[3]
        end

        it 'value is 3' do
          expect(@item.value).to be 3
        end

        it 'symbol value is local::at0003.3' do
          expect(@item.symbol.value).to eq('[local::at0003.3]')
        end
      end

      context '5th item' do
        before(:all) do
          @item = @at.list[4]
        end

        it 'value is 4' do
          expect(@item.value).to be 4
        end

        it 'symbol value is local::at0003.4' do
          expect(@item.symbol.value).to eq('[local::at0003.4]')
        end
      end

      context '6th item' do
        before(:all) do
          @item = @at.list[5]
        end

        it 'item is nil' do
          expect(@item).to be_nil
        end
      end
    end

    context '2nd ordinals chunk' do
      before(:all) do
        @at = attr(2)
      end

      it 'is an instance of CDvOrdinal' do
        expect(@at).to be_an_instance_of CDvOrdinal
      end

      context '1st item' do
        before(:all) do
          @item = @at.list[0]
        end

        it 'value is 0' do
          expect(@item.value).to be 0
        end

        it 'symbol value is local::at0003.0]' do
          expect(@item.symbol.value).to eq('[local::at0003.0]')
        end

        it 'defining code terminology is local' do
          expect(@item.symbol.defining_code.terminology_id.value).to eq('local')
        end

        it 'defining code string is at0003.0' do
          expect(@item.symbol.defining_code.code_string).to eq('at0003.0')
        end
      end

      context '2nd item' do
        before(:all) do
          @item = @at.list[1]
        end

        it 'value is 1' do
          expect(@item.value).to be 1
        end

        it 'symbol value is local::at0003.1' do
          expect(@item.symbol.value).to eq('[local::at0003.1]')
        end
      end

      context '3nd item' do
        before(:all) do
          @item = @at.list[2]
        end

        it 'value is 2' do
          expect(@item.value).to be 2
        end

        it 'symbol value is local::at0003.2' do
          expect(@item.symbol.value).to eq('[local::at0003.2]')
        end
      end

      context '4th item' do
        before(:all) do
          @item = @at.list[3]
        end

        it 'value is 3' do
          expect(@item.value).to be 3
        end

        it 'symbol value is local::at0003.3' do
          expect(@item.symbol.value).to eq('[local::at0003.3]')
        end
      end

      context '5th item' do
        before(:all) do
          @item = @at.list[4]
        end

        it 'value is 3' do
          expect(@item.value).to be 4
        end

        it 'symbol value is local::at0003.4' do
          expect(@item.symbol.value).to eq('[local::at0003.4]')
        end
      end

      context '6th item' do
        before(:all) do
          @item = @at.list[5]
        end

        it 'item is nil' do
          expect(@item).to be_nil
        end
      end

      it 'has assumed value' do
        expect(@at).to have_assumed_value
      end

      it 'assumed_value is 0' do
        expect(@at.assumed_value).to be 0
      end
    end

    context '3rd ordinal is any allowed' do
      before(:all) do
        @at = attr(3)
      end

      it 'is any allowed' do
        expect(@at).to be_any_allowed
      end
    end
  end
end
