require File.dirname(__FILE__) + '/../../../spec_helper'
include OpenEHR::Parser

describe ADLParser do

  before do
    @parser = ADLParser.new
  end

  it 'create valid instance' do
    @parser.should be_an_instance_of ADLParser
  end

  context 'to parse openEHR-EHR-SECTION.reason_for_encounter.v1.adl' do
    before do
      current_dir = File.dirname(__FILE__)
      file =  File.read(current_dir + '/adl/openEHR-EHR-SECTION.reason_for_encounter.v1.adl')
      @adl = @parser.parse(file, 'openEHR-EHR-SECTION.reason_for_encounter.v1')
    end

    it 'parse adl and create an reference model' do
      @adl.archetype_id.should be_an_instance_of OpenEHR::RM::Support::Identification::ArchetypeID
    end
  end
end
