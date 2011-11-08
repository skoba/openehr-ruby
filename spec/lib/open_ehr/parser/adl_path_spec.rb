require File.dirname(__FILE__) + '/../../../spec_helper'
include OpenEHR::Parser
include OpenEHR::AM::Archetype
include OpenEHR::AM::Archetype::ConstraintModel
include OpenEHR::AM::Archetype::Assertion
include OpenEHR::AM::Archetype::Ontology

describe ADLParser do
  before(:all) do
    adl_dir = File.dirname(__FILE__) + '/adl14/'
    adl_path_test_file = 'adl-test-car.paths.test.adl'
    ap = OpenEHR::Parser::ADLParser.new(adl_dir + adl_path_test_file)
    @root = ap.parse.definition
  end

  
  it 'root path is /' do
    @root.path.should == '/'
  end

  context 'wheels' do
    before do
     @wheels = @root.attributes[0]
    end

    it 'wheels path is /whees' do
      @wheels.path.should == '/wheels'
    end

    context 'first wheel path' do
      before do
        @first_wheel = @wheels.children[0]
      end
      it 'first wheel path is /wheels[at0001]' do
        @first_wheel.path.should == '/wheels[at0001]'
      end
    end
  end
end
