require  File.dirname(__FILE__) + '/../../../spec_helper'

module OpenEHR
  module RM
    describe Factory do
      context "DvText generation" do
        subject { Factory.create("DvText", value: 'text') }
        it { should be_an_instance_of OpenEHR::RM::DataTypes::Text::DvText }
      end

      context "DV_TEXT mapped to camelized RM type" do
        subject { Factory.create('DV_TEXT', value:'text') }
        it { should be_an_instance_of OpenEHR::RM::DataTypes::Text::DvText }
      end

      context "DvQuantity generation" do
        subject { Factory.create("DvQuantity", magnitude: 10, units: 'mg') }
        it { should be_an_instance_of OpenEHR::RM::DataTypes::Quantity::DvQuantity }
      end
    end
  end
end
