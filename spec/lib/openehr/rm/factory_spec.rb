require  File.dirname(__FILE__) + '/../../../spec_helper'

module OpenEHR
  module RM
    describe Factory do
      context "DvBoolean generation" do
        subject { Factory.create('DvBoolean', value: true) }
        it { should be_an_instance_of OpenEHR::RM::DataTypes::Basic::DvBoolean }
      end

      context "DvText generation" do
        subject { Factory.create("DvText", value: 'text') }
        it { should be_an_instance_of OpenEHR::RM::DataTypes::Text::DvText }
      end

      context "DV_TEXT mapped to camelized RM type" do
        subject { Factory.create('DV_TEXT', value:'text') }
        it { should be_an_instance_of OpenEHR::RM::DataTypes::Text::DvText }
      end

      context "DvCodedText generation" do
        subject { Factory.create('DV_CODED_TEXT', value: 'C089', defining_code: double()) }
        it { should be_an_instance_of OpenEHR::RM::DataTypes::Text::DvCodedText }
      end

      context "DvQuantity generation" do
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
