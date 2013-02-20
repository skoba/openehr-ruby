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

      describe DvOrdinalFactory do
        subject { Factory.create('DV_ORDINAL', value: 1, symbol: double()) }

        it { should be_an_instance_of OpenEHR::RM::DataTypes::Quantity::DvOrdinal }
      end

      describe DvQuantifiedFactory do
        subject { Factory.create('DV_QUANTIFIED', magnitude: 1) }

        it { should be_an_instance_of OpenEHR::RM::DataTypes::Quantity::DvQuantified }
      end

      describe DvAmountFactory do
        subject { Factory.create('DV_AMOUNT', magnitude: 0) }

        it { should be_an_instance_of DataTypes::Quantity::DvAmount }
      end

      describe DvQuantityFactory do
        subject { Factory.create("DvQuantity", magnitude: 10, units: 'mg') }

        it { should be_an_instance_of OpenEHR::RM::DataTypes::Quantity::DvQuantity }
      end

      describe DvCountFactory do
        subject { Factory.create("DV_COUNT", magnitude: 3) }

        it { should be_an_instance_of DataTypes::Quantity::DvCount }
      end

      describe DvProportionFactory do
        subject { Factory.create('DV_PROPORTION', numerator: 2, denominator: 1,
                      type: DataTypes::Quantity::ProportionKind::PK_UNITARY) }

        it { should be_an_instance_of DataTypes::Quantity::DvProportion }
      end

      describe DvAbsoluteQuantityFactory do
        subject { Factory.create('DV_ABSOLUTE_QUANTITY', magnitude: 6) }

        it { should be_an_instance_of DataTypes::Quantity::DvAbsoluteQuantity }
      end

      describe DvTemporalFactory do
        subject { Factory.create('DV_TEMPORAL', value: '2013-02-20T02:09:30') }

        it { should be_an_instance_of DataTypes::Quantity::DateTime::DvTemporal }
      end

      describe DvDateFactory do
        subject { Factory.create("DV_DATE", value: '2013-02-19') }

        it { should be_an_instance_of OpenEHR::RM::DataTypes::Quantity::DateTime::DvDate }
      end

      describe DvTimeFactory do
        subject { Factory.create('DV_TIME', value: '02:13:39') }

        it { should be_an_instance_of DataTypes::Quantity::DateTime::DvTime }
      end

      describe DvDateTimeFactory do
        subject { Factory.create('DV_DATE_TIME', value: '2013-02-21T01:02:23') }

        it { should be_an_instance_of DataTypes::Quantity::DateTime::DvDateTime }
      end

      describe DvDurationFactory do
        subject { Factory.create('DV_DURATION', value: 'P1Y2M') }

        it { should be_an_instance_of DataTypes::Quantity::DateTime::DvDuration }
      end

      describe DvEncapsulatedFactory do
        subject { Factory.create('DV_ENCAPSULATED', value: 'sample') }

        it { should be_an_instance_of DataTypes::Encapsulated::DvEncapsulated }
      end

      describe DvMultimediaFactory do
        subject { media_type = stub('media_type')
          media_type.stub(:code_string).and_return('SVG')
          Factory.create('DV_MULTIMEDIA', value: '<SVG> test </SVG>',
                                 media_type: media_type) }

        it { should be_an_instance_of DataTypes::Encapsulated::DvMultimedia }
      end

      describe DvParsableFactory do
        subject { Factory.create('DvParsable', value: 'test', formalism: 'plain/text') }

        it { should be_an_instance_of DataTypes::Encapsulated::DvParsable }
      end

      describe DvUriFactory do
        subject { Factory.create('DV_URI', value: 'http://openehr.jp') }

        it { should be_an_instance_of DataTypes::URI::DvUri }
      end

      describe DvEhrUriFactory do
        subject { Factory.create('DV_EHR_URI', value: 'ehr://test/87284370-2D4B-4e3d-A3F3-F303D2F4F34B@2005-08-02T04:30:00') }

        it { should be_an_instance_of DataTypes::URI::DvEhrUri }
      end
    end
  end
end
