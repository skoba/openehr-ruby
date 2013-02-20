require  File.dirname(__FILE__) + '/../../../spec_helper'

module OpenEHR
  module RM
    describe Factory do
      describe DvBooleanFactory do
        subject { Factory.create('DvBoolean', value: true) }
        it { should be_an_instance_of OpenEHR::RM::DataTypes::Basic::DvBoolean }
      end

      describe DvStateFactory do
        subject { Factory.create('DV_STATE', value: double(), terminal: true) }
        it { should be_an_instance_of OpenEHR::RM::DataTypes::Basic::DvState }
      end

      describe DvIdentifierFactory do
        subject { Factory.create('DV_IDENTIFIER',
                                 issuer: 'Ehime univ', assigner: 'Hospital',
                                 id: '012345', type: 'local id') }
        it { should be_an_instance_of OpenEHR::RM::DataTypes::Basic::DvIdentifier }
      end

      describe DvTextFactory do
        subject { Factory.create("DvText", value: 'text') }
        it { should be_an_instance_of OpenEHR::RM::DataTypes::Text::DvText }
      end

      context "DV_TEXT mapped to camelized RM type" do
        subject { Factory.create('DV_TEXT', value:'text') }
        it { should be_an_instance_of OpenEHR::RM::DataTypes::Text::DvText }
      end

      describe DvCodedTextFactory do
        subject { Factory.create('DV_CODED_TEXT', value: 'C089', defining_code: double()) }
        it { should be_an_instance_of OpenEHR::RM::DataTypes::Text::DvCodedText }
      end

      context DvQuantityFactory do
        subject { Factory.create("DvQuantity", magnitude: 10, units: 'mg') }
        it { should be_an_instance_of OpenEHR::RM::DataTypes::Quantity::DvQuantity }
      end

      context DvDateFactory do
        subject { Factory.create("DV_DATE", value: '2013-02-19') }
        it { should be_an_instance_of OpenEHR::RM::DataTypes::Quantity::DateTime::DvDate }
      end
    end
  end
end
