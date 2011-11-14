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

    it 'wheels path is /wheels' do
      @wheels.path.should == '/wheels'
    end

    context 'first wheel' do
      before do
        @first_wheel = @wheels.children[0]
      end

      it 'path is /wheels[at0001]' do
        @first_wheel.path.should == '/wheels[at0001]'
      end

      it 'description path is /wheels[at0001]/description' do
        description = @first_wheel.attributes[0]
        description.path.should == '/wheels[at0001]/description'
      end

      it 'wheel parts path is /wheels[at0001]/parts' do
        wheel_parts = @first_wheel.attributes[1]
        wheel_parts.path.should == '/wheels[at0001]/parts'
      end
    end
  end
end
