require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/parser_spec_helper'
require 'openehr/am/openehr_profile/data_types/quantity'
include OpenEHR::AM::OpenEHRProfile::DataTypes::Quantity

describe ADLParser do
  describe CDvOrdinal do
    before(:all) do
      @archetype = adl14_archetype('openEHR-EHR-OBSERVATION.apgar.v1.adl')
    end

    it 'archetype should be parsed' do
      expect(@archetype).not_to be_nil
    end

    it 'archetype_id is openEHR-EHR-OBSERVATION.apgar.v1' do
      expect(@archetype.archetype_id.value).to eq 'openEHR-EHR-OBSERVATION.apgar.v1'
    end

    it 'concept is at0000' do
      expect(@archetype.concept).to eq 'at0000'
    end
  end
end
