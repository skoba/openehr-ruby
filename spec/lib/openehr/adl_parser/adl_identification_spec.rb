require File.dirname(__FILE__) + '/../../../spec_helper'
include OpenEHR::Parser

describe ADLParser do
  context 'ADL identification' do
    before(:all) do
      adl_dir = File.dirname(__FILE__) + '/adl14/'
      adl_id_test_file = 'adl-test-entry.archetype_identification.test.adl'
      ap = ADLParser.new(adl_dir + adl_id_test_file)
      archetype = ap.parse
      @adl_version = archetype.adl_version
    end

    it 'ADL version is 1.4' do
      expect(@adl_version).to eq('1.4')
    end
  end
end
