# ticket 174
require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/parser_spec_helper'
require 'open_ehr/am/openehr_profile/data_types/quantity'
include ::OpenEHR::AM::OpenEHRProfile::DataTypes::Quantity
require 'open_ehr/rm/data_types/quantity'
include ::OpenEHR::RM::DataTypes::Quantity

describe ADLParser do
  describe CDvQuantity do
    before(:all) do
      archetype = adl14_archetype('adl-test-entry.c_dv_quantity_full.test.adl')
      @c_dv_quantity = archetype.definition.attributes[0].children[0].attributes[0].children[0].attributes[0].children[0]
    end

    it 'is an instance of CDvQuantity' do
      @c_dv_quantity.should be_an_instance_of CDvQuantity
    end

    context 'property' do
      before(:all) do
        @property = @c_dv_quantity.property
      end

      it 'property should not be nil' do
        @property.should_not be_nil
      end

      it 'property terminology id should openehr' do
        @property.terminology_id.name.should == 'openehr'
      end

      it 'property code_string is 128' do
        @property.code_string.should == '128'
      end
    end

    context 'item list' do
      before(:all) do
        @list = @c_dv_quantity.list
      end

      it 'size is 2' do
        @list.size.should be 2
      end

      context 'first item' do
        before(:all) do
          @first = @list[0]
        end

        it 'first is an isntance of CQuantityItem' do
          @first.should be_an_instance_of CQuantityItem
        end
        it 'units is yr' do
          @first.units.should == 'yr'
        end

        it 'magnitude lower is 0.0' do
          @first.magnitude.lower.should == 0.0
        end

        it 'magnitude upper is 200.0' do
          @first.magnitude.upper.should == 200.0
        end

        it 'precision upper is 2' do
          @first.precision.upper.should be 2
        end

        it 'precision lower is 2, too' do
          @first.precision.lower.should be 2
        end
      end

      context 'secocond item' do
        before(:all) do
          @second = @list[1]
        end

        it 'is an instance of CQuantityItem' do
          @second.should be_an_instance_of CQuantityItem
        end

        it 'unit is mth' do
          @second.units.should == 'mth'
        end

        it 'magnitude lower is 1.0' do
          @second.magnitude.lower.should == 1.0
        end

        it 'magnitude upper is 36.0' do
          @second.magnitude.upper.should == 36.0
        end

        it 'precision upper is 2' do
          @second.precision.upper.should == 2
        end

        it 'precision lower is 2' do
          @second.precision.lower.should == 2
        end
      end

      context 'assumed value' do
        before(:all) do
          @assumed_value = @c_dv_quantity.assumed_value
        end

        it 'is an instance of CQuantityItem' do
          @assumed_value.should be_an_instance_of DvQuantity
        end

        it 'units is yr' do
          @assumed_value.units.should == 'yr'
        end

        it 'magnitude is 8.0' do
          @assumed_value.magnitude.should == 8.0
        end

        it 'precision is 2' do
          @assumed_value.precision.should be 2
        end
      end
    end
  end
end
