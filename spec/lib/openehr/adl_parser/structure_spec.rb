# ticket 187
require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/parser_spec_helper'

describe ADLParser do
  context 'Structure spec' do
    before(:all) do
      archetype = adl14_archetype('adl-test-entry.structure_test1.test.adl')
      @definition = archetype.definition
      @occurrences = OpenEHR::AssumedLibraryTypes::Interval.new(
                       :upper => 1, :lower => 1, 
                       :lower_included => true, :upper_included => true)
    end

    context 'root definition object' do
      it 'rm_type_name is ENTRY' do
        expect(@definition.rm_type_name).to eq('ENTRY')
      end

      it 'path is /' do
        expect(@definition.path).to eq('/')
      end

      it 'node_id is at0000' do
        expect(@definition.node_id).to eq('at0000')
      end

      it 'occurrences is default 1,1' do
        expect(@definition.occurrences).to eq(@occurrences)
      end

      it 'attributes size is 2' do
        expect(@definition.attributes.size).to be 2
      end
    end

    context 'first attribute' do
      before(:all) do
        @attr = @definition.attributes[0]
      end

      it 'rm_attribute_name is subject_relationship' do
        expect(@attr.rm_attribute_name).to eq('subject_relationship')
      end

      it 'has 1 child' do
        expect(@attr.children.size).to be 1
      end

      context '2nd level object' do
        before(:all) do
          @obj = @attr.children[0]
        end

        it 'rm type name is RELATED_PARTY' do
          expect(@obj.rm_type_name).to eq('RELATED_PARTY')
        end

        it 'node id shold be nil' do
          expect(@obj.node_id).to be_nil
        end

        it 'occurrences is default' do
          expect(@obj.occurrences).to eq(@occurrences)
        end

        it 'attributes size is 1' do
          expect(@obj.attributes.size).to be 1
        end

        context 'attribute of 2nd level object' do
          before(:all) do
            @attr = @obj.attributes[0]
          end

          it 'rm attribute name is relationship' do
            expect(@attr.rm_attribute_name).to eq('relationship')
          end

          it 'children size is 1' do
            expect(@attr.children.size).to be 1
          end

          context 'leaf object' do
            before(:all) do
              @leaf = @attr.children[0]
            end

            it 'rm type name is TEXT' do
              expect(@leaf.rm_type_name).to eq('TEXT')
            end

            it 'occurences is default' do
              expect(@leaf.occurrences).to eq(@occurrences)
            end

            it 'node id should be nil' do
              expect(@leaf.node_id).to be_nil
            end

            it 'attributes size is 1' do
              expect(@leaf.attributes.size).to be 1
            end

            context 'attribute of leaf object' do
              before(:all) do
                @attr = @leaf.attributes[0]
              end

              it 'rm attribute name is value' do
                expect(@attr.rm_attribute_name).to eq('value')
              end

              it 'children size is 1' do
                expect(@attr.children.size).to be 1
              end

              context 'primitive constraint of leaf object' do
                before(:all) do
                  @cstring = @attr.children[0]
                end

                it 'string constraint pattern is nil' do
                  expect(@cstring.pattern).to be_nil
                end

                it 'list constraint is self' do
                  expect(@cstring.list).to eq(['self'])
                end

                it 'list size is 1' do
                  expect(@cstring.list.size).to be 1
                end
              end
            end
          end
        end
      end
    end

    context 'second attribute of root' do
      before(:all) do
        @attr = @definition.attributes[1]
      end

      it 'rm attribute name is members' do
        expect(@attr.rm_attribute_name).to eq('members')
      end

      it 'existence are 0..1' do
        existence = OpenEHR::AssumedLibraryTypes::Interval.new(
                        :lower => 0, :upper => 1,
                        :lower_included => true, :upper_included => true)
        expect(@attr.existence).to eq(existence)
      end

      it 'cardinality interval is 0..8' do
        interval = OpenEHR::AssumedLibraryTypes::Interval.new(
                        :lower => 0, :upper => 8,
                        :lower_included => true, :upper_included => true)
        expect(@attr.cardinality.interval).to eq(interval)
      end

      it 'children size are 2' do
        expect(@attr.children.size).to be 2
      end

      context '1st person' do
        before(:all) do
          @first = @attr.children[0]
        end

        it 'rm type name is PERSON' do
          expect(@first.rm_type_name).to eq('PERSON')
        end

        it 'occurrences are default' do
          expect(@first.occurrences).to eq(@occurrences)
        end

        it 'attributes size is 1' do
          expect(@first.attributes.size).to be 1
        end
      end

      context '2nd person' do
        before(:all) do
          @second = @attr.children[1]
        end

        it 'rm type name is PERSON' do
          expect(@second.rm_type_name).to eq('PERSON')
        end

        it 'occurences is upper unbounded' do
          occurrences = OpenEHR::AssumedLibraryTypes::Interval.new(
                          :lower => 0, :lower_included => true)
          expect(@second.occurrences).to eq(occurrences)
        end

        
      end
    end
  end
end
