require File.dirname(__FILE__) + '/../../../spec_helper'
include OpenEHR::Parser

describe ADLParser do

  before (:all) do
    @adl_dir = File.dirname(__FILE__)+'/adl/'
  end

  context 'openEHR-EHR-SECTION-summary.v1.adl' do
    before do
      @ap = ADLParser.new(@adl_dir + 'openEHR-EHR-SECTION.summary.v1.adl')
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
        @archetype.archetype_id.should be_equal 'openEHR-EHR-SECTION-summary'
      end
    end
  end
end
