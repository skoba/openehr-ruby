require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/parser_spec_helper'
require 'openehr/am/openehr_profile/data_types/quantity'
include OpenEHR::AM::OpenEHRProfile::DataTypes::Quantity

describe ADLParser do
  describe CDvOrdinal do
    before(:all) do
      @archetype = adl14_archetype('adl-test-entry.c_dv_ordinal.test.adl')
    end

    it 'archetype should be parsed' do
      expect(@archetype).not_to be_nil
    end
  end
end
