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
    before(:all) do
     @wheels = @root.attributes[0]
    end

    it 'wheels path is /wheels' do
      @wheels.path.should == '/wheels'
    end

    context 'first wheel' do
      before(:all) do
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

      context 'under first wheel part node' do
        before(:all) do
          @wheel_part_node = @first_wheel.attributes[1].children[0]
        end
        
        it 'wheel part node path is /wheels[at0001]/parts[at0002]' do
          @wheel_part_node.path.should == '/wheels[at0001]/parts[at0002]'
        end

        context 'somthing of wheel part' do
          before(:all) do
            @something = @wheel_part_node.attributes[0]
          end

          it 'something of WHEEL_PART path is /wheels[at0001]/parts[at0002]/something' do
            @something.path.should == '/wheels[at0001]/parts[at0002]/something'
          end
        end

        context 'somthing else of wheel part' do
          before(:all) do
            @something_else = @wheel_part_node.attributes[1]
          end

          it 'something else of WHEEL_PART path is /wheels[at0001]/parts[at0002]/something_else' do
            @something_else.path.should ==
              '/wheels[at0001]/parts[at0002]/something_else'
          end
        end
      end
    end
  end
end
