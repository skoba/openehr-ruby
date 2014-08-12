# ticket 174
require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/parser_spec_helper'
require 'openehr/am/openehr_profile/data_types/quantity'
include ::OpenEHR::AM::OpenEHRProfile::DataTypes::Quantity
require 'openehr/rm/data_types/quantity'
include ::OpenEHR::RM::DataTypes::Quantity

shared_examples 'c_dv_quantity' do
  context 'CDvQuantity item order change' do
    let(:c_dv_quantity) {archetype.definition.attributes[0].children[0].attributes[0].children[0].attributes[0].children[0]}

    it 'is an instance of CDvQuantity' do
      expect(c_dv_quantity).to be_an_instance_of CDvQuantity
    end

    context 'property' do
      let (:property) { c_dv_quantity.property}

      it 'property should not be nil' do
        expect(property).not_to be_nil
      end

      it 'property terminology id should openehr' do
        expect(property.terminology_id.name).to eq('openehr')
      end

      it 'property code_string is 128' do
        expect(property.code_string).to eq('128')
      end
    end

    context 'item list' do
      let(:list) { c_dv_quantity.list }

      it 'size is 2' do
        expect(list.size).to be 2
      end

      context 'first item' do
        let(:first) { list[0] }

        it 'first is an isntance of CQuantityItem' do
          expect(first).to be_an_instance_of CQuantityItem
        end
        it 'units is yr' do
          expect(first.units).to eq('yr')
        end

        it 'magnitude lower is 0.0' do
          expect(first.magnitude.lower).to eq(0.0)
        end

        it 'magnitude upper is 200.0' do
          expect(first.magnitude.upper).to eq(200.0)
        end

        it 'precision upper is 2' do
          expect(first.precision.upper).to be 2
        end

        it 'precision lower is 2, too' do
          expect(first.precision.lower).to be 2
        end
      end

      context 'secocond item' do
        let(:second) { list[1] }

        it 'is an instance of CQuantityItem' do
          expect(second).to be_an_instance_of CQuantityItem
        end

        it 'unit is mth' do
          expect(second.units).to eq('mth')
        end

        it 'magnitude lower is 1.0' do
          expect(second.magnitude.lower).to eq(1.0)
        end

        it 'magnitude upper is 36.0' do
          expect(second.magnitude.upper).to eq(36.0)
        end

        it 'precision upper is 2' do
          expect(second.precision.upper).to eq(2)
        end

        it 'precision lower is 2' do
          expect(second.precision.lower).to eq(2)
        end
      end

      context 'assumed value' do
        let(:assumed_value) { c_dv_quantity.assumed_value }

        it 'is an instance of CQuantityItem' do
          expect(assumed_value).to be_an_instance_of DvQuantity
        end

        it 'units is yr' do
          expect(assumed_value.units).to eq('yr')
        end

        it 'magnitude is 8.0' do
          expect(assumed_value.magnitude).to eq(8.0)
        end

        it 'precision is 2' do
          expect(assumed_value.precision).to be 2
        end
      end
    end
  end
end

describe 'items start with property' do
  it_behaves_like 'c_dv_quantity' do
    let(:archetype) {adl14_archetype('adl-test-entry.c_dv_quantity_full.test.adl')}
  end
end

describe 'items start with list' do
  it_behaves_like 'c_dv_quantity' do
    let(:archetype) { adl14_archetype('adl-test-entry.c_dv_quantity_full2.test.adl') }
  end
end

describe 'items start with assumed_value' do
  it_behaves_like 'c_dv_quantity' do
    let(:archetype) { adl14_archetype('adl-test-entry.c_dv_quantity_full3.test.adl') }
  end
end
