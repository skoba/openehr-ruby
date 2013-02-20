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

      describe TermMappingFactory do
        let(:target) { double() }
        subject { Factory.create('TERM_MAPPING', target: target, match: '=') }

        it { should be_an_instance_of OpenEHR::RM::DataTypes::Text::TermMapping }
      end

      describe CodePhraseFactory do
        let(:terminology_id) { double() }
        subject { Factory.create('CODE_PHRASE',
                                 terminology_id: terminology_id,
                                 code_string: 'C890') }

        it { should be_an_instance_of OpenEHR::RM::DataTypes::Text::CodePhrase }
      end

      describe DvCodedTextFactory do
        subject { Factory.create('DV_CODED_TEXT', value: 'C089', defining_code: double()) }

        it { should be_an_instance_of OpenEHR::RM::DataTypes::Text::DvCodedText }
      end

      describe DvParagraphFactory do
        let(:items) { ['short sentence', 'long sentence']}
        subject { Factory.create('DV_PARAGRAPH', items: items) }

        it { should be_an_instance_of OpenEHR::RM::DataTypes::Text::DvParagraph }
      end

      describe DvOrderedFactory do
        subject { Factory.create('DV_ORDERED') }

        it { should be_an_instance_of OpenEHR::RM::DataTypes::Quantity::DvOrdered }
      end

      describe DvIntervalFactory do
        subject { Factory.create('DV_INTERVAL', upper: 100, lower: 1) }

        it { should be_an_instance_of OpenEHR::RM::DataTypes::Quantity::DvInterval }
      end

      describe ReferenceRangeFactory do
        subject { Factory.create('REFERENCE_RANGE', meaning: 'spec', range: double) }
        it { should be_an_instance_of OpenEHR::RM::DataTypes::Quantity::ReferenceRange }
      end

      describe DvQuantityFactory do
        subject { Factory.create("DvQuantity", magnitude: 10, units: 'mg') }

        it { should be_an_instance_of OpenEHR::RM::DataTypes::Quantity::DvQuantity }
      end

      describe DvDateFactory do
        subject { Factory.create("DV_DATE", value: '2013-02-19') }
        it { should be_an_instance_of OpenEHR::RM::DataTypes::Quantity::DateTime::DvDate }
      end
    end
  end
end
