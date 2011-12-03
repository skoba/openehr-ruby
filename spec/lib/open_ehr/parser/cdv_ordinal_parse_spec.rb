require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/parser_spec_helper'
require 'open_ehr/am/openehr_profile/data_types/quantity'
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
        @at.should be_an_instance_of CDvOrdinal
      end

      context '1st item' do
        before(:all) do
          @item = @at.list[0]
        end

        it 'value is 0' do
          @item.value.should be 0
        end

        it 'symbol value is local::at0003.0]' do
          @item.symbol.value.should == '[local::at0003.0]'
        end

        it 'defining code terminology is local' do
          @item.symbol.defining_code.terminology_id.value.should == 'local'
        end

        it 'defining code string is at0003.0' do
          @item.symbol.defining_code.code_string.should == 'at0003.0'
        end
      end

      context '2nd item' do
        before(:all) do
          @item = @at.list[1]
        end

        it 'value is 1' do
          @item.value.should be 1
        end

        it 'symbol value is local::at0003.1' do
          @item.symbol.value.should == '[local::at0003.1]'
        end
      end

      context '3nd item' do
        before(:all) do
          @item = @at.list[2]
        end

        it 'value is 2' do
          @item.value.should be 2
        end

        it 'symbol value is local::at0003.2' do
          @item.symbol.value.should == '[local::at0003.2]'
        end
      end

      context '4th item' do
        before(:all) do
          @item = @at.list[3]
        end

        it 'value is 3' do
          @item.value.should be 3
        end

        it 'symbol value is local::at0003.3' do
          @item.symbol.value.should == '[local::at0003.3]'
        end
      end

      context '5th item' do
        before(:all) do
          @item = @at.list[4]
        end

        it 'value is 4' do
          @item.value.should be 4
        end

        it 'symbol value is local::at0003.4' do
          @item.symbol.value.should == '[local::at0003.4]'
        end
      end

      context '6th item' do
        before(:all) do
          @item = @at.list[5]
        end

        it 'item is nil' do
          @item.should be_nil
        end
      end
    end

    context '2nd ordinals chunk' do
      before(:all) do
        @at = attr(2)
      end

      it 'is an instance of CDvOrdinal' do
        @at.should be_an_instance_of CDvOrdinal
      end

      context '1st item' do
        before(:all) do
          @item = @at.list[0]
        end

        it 'value is 0' do
          @item.value.should be 0
        end

        it 'symbol value is local::at0003.0]' do
          @item.symbol.value.should == '[local::at0003.0]'
        end

        it 'defining code terminology is local' do
          @item.symbol.defining_code.terminology_id.value.should == 'local'
        end

        it 'defining code string is at0003.0' do
          @item.symbol.defining_code.code_string.should == 'at0003.0'
        end
      end

      context '2nd item' do
        before(:all) do
          @item = @at.list[1]
        end

        it 'value is 1' do
          @item.value.should be 1
        end

        it 'symbol value is local::at0003.1' do
          @item.symbol.value.should == '[local::at0003.1]'
        end
      end

      context '3nd item' do
        before(:all) do
          @item = @at.list[2]
        end

        it 'value is 2' do
          @item.value.should be 2
        end

        it 'symbol value is local::at0003.2' do
          @item.symbol.value.should == '[local::at0003.2]'
        end
      end

      context '4th item' do
        before(:all) do
          @item = @at.list[3]
        end

        it 'value is 3' do
          @item.value.should be 3
        end

        it 'symbol value is local::at0003.3' do
          @item.symbol.value.should == '[local::at0003.3]'
        end
      end

      context '5th item' do
        before(:all) do
          @item = @at.list[4]
        end

        it 'value is 3' do
          @item.value.should be 4
        end

        it 'symbol value is local::at0003.4' do
          @item.symbol.value.should == '[local::at0003.4]'
        end
      end

      context '6th item' do
        before(:all) do
          @item = @at.list[5]
        end

        it 'item is nil' do
          @item.should be_nil
        end
      end

      it 'has assumed value' do
        @at.should have_assumed_value
      end

      it 'assumed_value is 0' do
        @at.assumed_value.should be 0
      end
    end

    context '3rd ordinal is any allowed' do
      before(:all) do
        @at = attr(3)
      end

      it 'is any allowed' do
        @at.should be_any_allowed
      end
    end
  end
end
