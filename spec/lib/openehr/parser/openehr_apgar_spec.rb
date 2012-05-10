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
      @archetype.should_not be_nil
    end
  end
end
