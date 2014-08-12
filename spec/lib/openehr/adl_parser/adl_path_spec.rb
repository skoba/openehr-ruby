require File.dirname(__FILE__) + '/../../../spec_helper'
include OpenEHR::Parser


describe ADLParser do
  before(:all) do
    adl_dir = File.dirname(__FILE__) + '/adl14/'
    adl_path_test_file = 'adl-test-car.paths.test.adl'
    ap = ADLParser.new(adl_dir + adl_path_test_file)
    @root = ap.parse.definition
  end

  it 'root path is /' do
    expect(@root.path).to eq('/')
  end

  context 'wheels' do
    before(:all) do
     @wheels = @root.attributes[0]
    end

    it 'wheels path is /wheels' do
      expect(@wheels.path).to eq('/wheels')
    end

    context 'first wheel' do
      before(:all) do
        @first_wheel = @wheels.children[0]
      end

      it 'path is /wheels[at0001]' do
        expect(@first_wheel.path).to eq('/wheels[at0001]')
      end

      it 'description path is /wheels[at0001]/description' do
        description = @first_wheel.attributes[0]
        expect(description.path).to eq('/wheels[at0001]/description')
      end

      it 'wheel parts path is /wheels[at0001]/parts' do
        wheel_parts = @first_wheel.attributes[1]
        expect(wheel_parts.path).to eq('/wheels[at0001]/parts')
      end

      context 'parts node' do
        before(:all) do
          @parts_node = @first_wheel.attributes[1].children[0]
        end
        
        it 'parts node path is /wheels[at0001]/parts[at0002]' do
          expect(@parts_node.path).to eq('/wheels[at0001]/parts[at0002]')
        end

        context 'somthing of wheel part' do
          before(:all) do
            @something = @parts_node.attributes[0]
          end

          it 'something of WHEEL_PART path is /wheels[at0001]/parts[at0002]/something' do
            expect(@something.path).to eq('/wheels[at0001]/parts[at0002]/something')
          end
        end

        context 'somthing else of wheel part' do
          before(:all) do
            @something_else = @parts_node.attributes[1]
          end

          it 'something else of WHEEL_PART path is /wheels[at0001]/parts[at0002]/something_else' do
            expect(@something_else.path).to eq(
              '/wheels[at0001]/parts[at0002]/something_else'
            )
          end
        end
      end
    end

    context 'second wheel' do
      before(:all) do
        @second_wheel = @wheels.children[1]
      end

      it 'path is /wheels[at0003]' do
        expect(@second_wheel.path).to eq('/wheels[at0003]')
      end

      it 'description path is /wheels[at0003]/description' do
        description = @second_wheel.attributes[0]
        expect(description.path).to eq('/wheels[at0003]/description')
      end

      it 'wheel parts path is /wheels[at0003]/parts' do
        wheel_parts = @second_wheel.attributes[1]
        expect(wheel_parts.path).to eq('/wheels[at0003]/parts')
      end

      context 'parts node' do
        before(:all) do
          @parts_node = @second_wheel.attributes[1].children[0]
        end

        it 'wheel parts node path is /wheels[at0003]/parts' do
          expect(@parts_node.path).to eq('/wheels[at0003]/parts')
        end

        it 'wheel parts node target path is /wheels[at0001]/parts[at0002]' do
          expect(@parts_node.target_path).to eq('/wheels[at0001]/parts[at0002]')
        end
      end
    end

    context 'third wheel' do
      before(:all) do
        @third_wheel = @wheels.children[2]
      end

      it 'path is /wheels[at0004]' do
        expect(@third_wheel.path).to eq('/wheels[at0004]')
      end

      it 'description path is /wheels[at0004]/description' do
        description = @third_wheel.attributes[0]
        expect(description.path).to eq('/wheels[at0004]/description')
      end

      context 'parts node' do
        before(:all) do
          @parts_node = @third_wheel.attributes[1].children[0]
        end

        it 'parts node path is /wheels[at0004]/parts' do
          expect(@parts_node.path).to eq('/wheels[at0004]/parts')
        end

        it 'parts node target path is /wheels[at0001]/parts[at0002]' do
          expect(@parts_node.target_path).to eq('/wheels[at0001]/parts[at0002]')
        end
      end
    end

    context 'fourth wheel' do
      before(:all) do
        @fourth_wheel = @wheels.children[3]
      end

      it 'path is /wheels[at0005]' do
        expect(@fourth_wheel.path).to eq('/wheels[at0005]')
      end

      it 'description path is /wheels[at0005]/description' do
        description = @fourth_wheel.attributes[0]
        expect(description.path).to eq('/wheels[at0005]/description')
      end

      context 'parts node' do
        before(:all) do
          @parts_node = @fourth_wheel.attributes[1].children[0]
        end

        it 'parts node path is /wheels[at0005]/parts' do
          expect(@parts_node.path).to eq('/wheels[at0005]/parts')
        end

        it 'parts node target path is /engine[at0001]/parts[at0002]' do
          expect(@parts_node.target_path).to eq('/engine[at0001]/parts[at0002]')
        end
      end
    end

    context 'fifhth wheel' do
      it 'fifth wheel is nil' do
        fifth_wheel = @wheels.children[4]
        expect(fifth_wheel).to be_nil
      end
    end
  end
end
