require File.dirname(__FILE__) + '/../../../spec_helper'

describe OpenEHR::RM do
  describe '.type_name_of' do
    it 'derives the RM type name from an instance' do
      quantity = OpenEHR::RM::DataTypes::Quantity::DvQuantity.new(:magnitude => 1.0,
                                                                   :units => 'mm[Hg]')
      expect(OpenEHR::RM.type_name_of(quantity)).to eq('DV_QUANTITY')
    end

    it 'derives the RM type name from a class' do
      expect(OpenEHR::RM.type_name_of(OpenEHR::RM::DataTypes::Basic::DvBoolean)).to eq('DV_BOOLEAN')
    end

    it 'handles acronym-heavy class names' do
      expect(OpenEHR::RM.type_name_of(OpenEHR::RM::Support::Identification::HierObjectID)).to eq('HIER_OBJECT_ID')
    end
  end

  describe '.class_for' do
    it 'resolves a spec type name to its RM class' do
      expect(OpenEHR::RM.class_for('DV_QUANTITY')).to equal(OpenEHR::RM::DataTypes::Quantity::DvQuantity)
    end

    it 'is case-insensitive' do
      expect(OpenEHR::RM.class_for('dv_quantity')).to equal(OpenEHR::RM::DataTypes::Quantity::DvQuantity)
    end

    it 'also accepts a bare CamelCase class name (some CDomainType constraints store rm_type_name this way)' do
      expect(OpenEHR::RM.class_for('DvQuantity')).to equal(OpenEHR::RM::DataTypes::Quantity::DvQuantity)
    end

    it 'resolves an abstract/superclass type name too' do
      expect(OpenEHR::RM.class_for('DV_ORDERED')).to equal(OpenEHR::RM::DataTypes::Quantity::DvOrdered)
    end

    it 'returns nil for an unknown type name' do
      expect(OpenEHR::RM.class_for('NOT_A_REAL_TYPE')).to be_nil
    end
  end

  describe '.subtype_of?' do
    let(:quantity) do
      OpenEHR::RM::DataTypes::Quantity::DvQuantity.new(:magnitude => 1.0, :units => 'mm[Hg]')
    end

    it 'is true when the instance is exactly the given type' do
      expect(OpenEHR::RM.subtype_of?(quantity, 'DV_QUANTITY')).to be true
    end

    it 'is true when the instance is a subtype of the given type' do
      expect(OpenEHR::RM.subtype_of?(quantity, 'DATA_VALUE')).to be true
      expect(OpenEHR::RM.subtype_of?(quantity, 'DV_ORDERED')).to be true
    end

    it 'is false when the instance is not a subtype of the given type' do
      expect(OpenEHR::RM.subtype_of?(quantity, 'DV_BOOLEAN')).to be false
    end

    it 'also accepts a class instead of an instance' do
      expect(OpenEHR::RM.subtype_of?(OpenEHR::RM::DataTypes::Quantity::DvQuantity, 'DV_ORDERED')).to be true
    end

    it 'is false when the given type name is unknown' do
      expect(OpenEHR::RM.subtype_of?(quantity, 'NOT_A_REAL_TYPE')).to be false
    end
  end
end
