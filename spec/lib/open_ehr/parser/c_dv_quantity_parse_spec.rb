require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/parser_spec_helper'
require 'open_ehr/am/openehr_profile/data_types/quantity'
include OpenEHR::AM::OpenEHRProfile::DataTypes::Quantity

describe ADLParser do
  describe CDvOrdinal do
    before(:all) do
      archetype = adl14_archetype('adl-test-entry.c_dv_quantity_full.test.adl')
      @attributes = archetype.definition.attributes
    end

    it 'attribute' do
      p @attributes
    end
  end
end
