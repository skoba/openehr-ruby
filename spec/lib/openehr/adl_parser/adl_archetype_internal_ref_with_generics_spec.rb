require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/parser_spec_helper'
include OpenEHR::AM::Archetype
include OpenEHR::AM::Archetype::ConstraintModel

describe ADLParser do
  context 'ArchetypeInternalRef with generics' do
    before(:all) do
      @archetype = adl14_archetype('adl-test-SOME_TYPE.generic_type_use_node.draft.adl')
    end

    it 'is a instance of Archetype' do
      expect(@archetype).to be_an_instance_of Archetype
    end

    context 'interval_attr1 node' do
      before(:all) do
        @node = @archetype.definition.attributes[0].children[0]
      end

     
      it 's path is /iterval_attr[at0001]' do
        expect(@node.path).to eq('/interval_attr[at0001]')
      end

      it 's rm type dis INTERVAL<QUANTITY>' do
        expect(@node.rm_type_name).to eq('INTERVAL<QUANTITY>')
      end

      context 'attributes' do
        before(:all) do
          @attributes = @node.attributes
        end

        context 'lower attribute' do
          before(:all) do
            @attribute = @attributes[0]
          end

          it 'path is /interval_attr[at0001]/lower' do
            expect(@attribute.path).to eq('/interval_attr[at0001]/lower')
          end

          context 'lower node' do
            before(:all) do
              @lower = @attribute.children[0]
            end

            it 'rm type name is QUANTITY' do
              expect(@lower.rm_type_name).to eq('QUANTITY')
            end

            context 'lower attributes' do
              before(:all) do
                @lower_attributes = @lower.attributes
              end

              context 'property' do
                before(:all) do
                  @property = @lower_attributes[0]
                end

                it 's path is /interval_attr[at0001]/lower/property' do
                  expect(@property.path).to eq('/interval_attr[at0001]/lower/property')
                end

                it 's rm attribute name is property' do
                  expect(@property.rm_attribute_name).to eq('property')
                end

                it 'is temprature' do
                  expect(@property.children[0].list).to eq(['temperature'])
                end
              end

              context 'unit' do
                before(:all) do
                  @unit = @lower_attributes[1]
                end

                it 's rm_attribute_name is unit' do
                  expect(@unit.rm_attribute_name).to eq('unit')
                end

                it 'matches C' do
                  expect(@unit.children[0].list).to eq(['C'])
                end
              end

              context 'magnitude' do
                before(:all) do
                  @magnitude = @lower_attributes[2]
                end

                it 's rm_attribute_name is magnitude' do
                  expect(@magnitude.rm_attribute_name).to eq('magnitude')
                end

                it 's lower is 37.0' do
                  expect(@magnitude.children[0].range.lower).to eq(37.0)
                end

                it 'is lower included' do
                  expect(@magnitude.children[0].range).to be_lower_included
                end

                it 'is upper unbounded' do
                  expect(@magnitude.children[0].range).to be_upper_unbounded
                end
              end
            end
          end
        end

        context 'upper attributes' do
          before(:all) do
            @attribute = @attributes[1]
          end
          
          it 'path is /interval_attr[at0001]/lower' do
            expect(@attribute.path).to eq('/interval_attr[at0001]/upper')
          end

          context 'upper node' do
            before(:all) do
              @upper = @attribute.children[0]
            end

            it 'rm type name is QUANTITY' do
              expect(@upper.rm_type_name).to eq('QUANTITY')
            end

            context 'upper attributes' do
              before(:all) do
                @upper_attributes = @upper.attributes
              end

              context 'property' do
                before(:all) do
                  @property = @upper.attributes[0]
                end

                it 's path is /interval_attr[at0001]/upper/property' do
                  expect(@property.path).to eq('/interval_attr[at0001]/upper/property')
                end

                it 's rm attribute name is property' do
                  expect(@property.rm_attribute_name).to eq('property')
                end

                it 'matches [temperature]' do
                  expect(@property.children[0].list).to eq(['temperature'])
                end
              end

              context 'unit' do
                before(:all) do
                  @unit = @upper_attributes[1]
                end

                it 's rm_attribute_name is unit' do
                  expect(@unit.rm_attribute_name).to eq('unit')
                end

                it 's matches C' do
                  expect(@unit.children[0].list).to eq(['C'])
                end
              end

              context 'magnitude' do
                before(:all) do
                  @magnitude = @upper_attributes[2]
                end

                it 's rm_attribute_name is magnitude' do
                  expect(@magnitude.rm_attribute_name).to eq('magnitude')
                end

                it 's magnitude lower is 39.0' do
                  expect(@magnitude.children[0].range.lower).to eq(39.0)
                end

                it 's magnitude lower included' do
                  expect(@magnitude.children[0].range).to be_lower_included
                end

                it 's upper unbounded' do
                  expect(@magnitude.children[0].range).to be_upper_unbounded
                end
              end
            end
          end
        end
        context 'lower_included attribute' do
          before(:all) do
            @attribute = @attributes[2]
          end

          it 's path is /interval_attr[at0001]/lower_included' do
            expect(@attribute.path).to eq('/interval_attr[at0001]/lower_included')
          end

          context 'lower_included node' do
            before(:all) do
              @lower_included = @attribute.children[0].item
            end

            it 'matches true valid' do
              expect(@lower_included).to be_true_valid
            end
          end
        end

        context 'upper_included attribute' do
          before(:all) do
            @attribute = @attributes[3]
          end

          it 's path is /interval_attr[at0001]/upper_included' do
            expect(@attribute.path).to eq('/interval_attr[at0001]/upper_included')
          end

          context 'upper_include node' do
            before(:all) do
              @upper_included = @attribute.children[0].item
            end

            it 'matches true valid' do
              expect(@upper_included).to be_true_valid
            end
          end
        end
      end
    end

    context 'interval_attr2 node' do
      before(:all) do
        @node = @archetype.definition.attributes[1].children[0]
      end

      it 'is an instance of ArchetypeInternalRef' do
        expect(@node).to be_an_instance_of ArchetypeInternalRef
      end

      it 's rm type name is INTERVAL<QUANTITY>' do
        expect(@node.rm_type_name).to eq('INTERVAL<QUANTITY>')
      end

      it 's target path is /interval_attr[at0001]' do
        expect(@node.target_path).to eq('/interval_attr[at0001]')
      end

      it 's path is /interval_attr2' do
        expect(@node.path).to eq('/interval_attr2')
      end
    end
  end
end
