require File.dirname(__FILE__) + '/../../../spec_helper'
include OpenEHR::Parser
include OpenEHR::AM::Archetype
include OpenEHR::AM::Archetype::ConstraintModel
include OpenEHR::AM::Archetype::Assertion
include OpenEHR::AM::Archetype::Ontology

describe ADLParser do
  before (:all) do
    adl_dir = File.dirname(__FILE__) + '/adl14/'
    adl_path_test_file = 'adl-test-car.paths.test.adl'
    ap = OpenEHR::Parser::ADLParser.new(adl_dir + adl_path_test_file)
    @a = ap.parse
  end

  it 'is an instance of Archetype' do
    @a.should be_an_instance_of Archetype
  end
  

end
