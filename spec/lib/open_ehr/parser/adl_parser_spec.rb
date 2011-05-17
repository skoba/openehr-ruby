require File.dirname(__FILE__) + '/../../../spec_helper'
include OpenEHR::Parser

describe ADLParser do

  before (:all) do
    @adl_dir = File.dirname(__FILE__)+'/adl/'
  end

  context 'openEHR-EHR-SECTION-summary.v1.adl' do
    before do
      @ap = ADLParser.new(@adl_dir + 'openEHR-EHR-SECTION-summary.v1.adl')
    end

    it 'archetype_id should be openEHR-EHR-SECTION-summary' do
      @ap.archetype_id.should be_equal 'openEHR-EHR-SECTION-summary'
    end
  end
end
