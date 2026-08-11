require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/parser_spec_helper'

describe 'a C_COMPLEX_OBJECT constrained to bare "*" (matches {*})' do
  it 'is any_allowed? on the object itself parsed from a real archetype' do
    archetype = adl14_archetype('openEHR-EHR-CLUSTER.anatomical_location.v1.adl')
    value_attribute = archetype.definition.attributes.first.children.first.attributes.first
    dv_text = value_attribute.children.first

    expect(dv_text).to be_any_allowed
  end
end
