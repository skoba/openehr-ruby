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
    @definition = ap.parse.definition
  end

  
  it 'root path is /' do
    @definition.path.should == '/'
  end


  it 'wheels path is /whees' do
    @definition.attributes[0].path.should == '/wheels'
  end
end
