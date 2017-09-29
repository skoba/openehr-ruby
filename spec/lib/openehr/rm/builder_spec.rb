require_relative File.dirname(__FILE__) + '/../adl_parser/parser_spec_helper'

describe OpenEHR::RM::RMBuilder do
  let(:archetype) { adl14_archetype('openEHR-EHR-INSTRUCTION.medication.v1.adl') }
  let(:definition) { archetype.definition }

  example 'reading attribute data' do
    expect(definition.attributes).not_to be_nil
  end
  
  example 'reading children data' do
    expect(definition.attributes[0].children).not_to be_nil
  end

  example 'reading data recursively'
end
