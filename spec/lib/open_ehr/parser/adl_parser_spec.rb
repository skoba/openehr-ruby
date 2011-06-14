require File.dirname(__FILE__) + '/../../../spec_helper'
include OpenEHR::Parser

describe ADLParser do

  before (:all) do
    @adl_dir = File.dirname(__FILE__)+'/adl/'
  end

  context 'openEHR-EHR-SECTION-summary.v1.adl' do
    before do
      @ap = OpenEHR::Parser::ADLParser.new(@adl_dir + 'openEHR-EHR-SECTION.summary.v1.adl')
    end

    context 'ADLParser generated from Citrus parser library' do
      it 'is an instance fo ADLParser' do
        @ap.should be_an_instance_of ADLParser
      end
    end

    context 'ADL parser generates archetype from ADL' do
      before do
        @archetype = @ap.parse
      end

      it 'archetype_id should be openEHR-EHR-SECTION-summary' do
        @archetype.archetype_id.should == 'openEHR-EHR-SECTION.summary.v1'
      end

      it 'adl_version should be 1.4' do
        @archetype.adl_version.should == '1.4'
      end

      it 'concept should be at0000]' do
        @archetype.concept.should == 'at0000'
      end

      it 'original language is ISO_639-1::en' do
        @archetype.original_language.should == 'ISO_639-1::en'
      end
    end
  end
end
