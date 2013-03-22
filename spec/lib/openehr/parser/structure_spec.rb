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
        @definition.rm_type_name.should == 'ENTRY'
      end

      it 'path is /' do
        @definition.path.should == '/'
      end

      it 'node_id is at0000' do
        @definition.node_id.should == 'at0000'
      end

      it 'occurrences is default 1,1' do
        @definition.occurrences.should == @occurrences
      end

      it 'attributes size is 2' do
        @definition.attributes.size.should be 2
      end
    end

    context 'first attribute' do
      before(:all) do
        @attr = @definition.attributes[0]
      end

      it 'rm_attribute_name is subject_relationship' do
        @attr.rm_attribute_name.should == 'subject_relationship'
      end

      it 'has 1 child' do
        @attr.children.size.should be 1
      end

      context '2nd level object' do
        before(:all) do
          @obj = @attr.children[0]
        end

        it 'rm type name is RELATED_PARTY' do
          @obj.rm_type_name.should == 'RELATED_PARTY'
        end

        it 'node id shold be nil' do
          @obj.node_id.should be_nil
        end

        it 'occurrences is default' do
          @obj.occurrences.should == @occurrences
        end

        it 'attributes size is 1' do
          @obj.attributes.size.should be 1
        end

        context 'attribute of 2nd level object' do
          before(:all) do
            @attr = @obj.attributes[0]
          end

          it 'rm attribute name is relationship' do
            @attr.rm_attribute_name.should == 'relationship'
          end

          it 'children size is 1' do
            @attr.children.size.should be 1
          end

          context 'leaf object' do
            before(:all) do
              @leaf = @attr.children[0]
            end

            it 'rm type name is TEXT' do
              @leaf.rm_type_name.should == 'TEXT'
            end

            it 'occurences is default' do
              @leaf.occurrences.should == @occurrences
            end

            it 'node id should be nil' do
              @leaf.node_id.should be_nil
            end

            it 'attributes size is 1' do
              @leaf.attributes.size.should be 1
            end

            context 'attribute of leaf object' do
              before(:all) do
                @attr = @leaf.attributes[0]
              end

              it 'rm attribute name is value' do
                @attr.rm_attribute_name.should == 'value'
              end

              it 'children size is 1' do
                @attr.children.size.should be 1
              end

              context 'primitive constraint of leaf object' do
                before(:all) do
                  @cstring = @attr.children[0]
                end

                it 'string constraint pattern is nil' do
                  @cstring.pattern.should be_nil
                end

                it 'list constraint is self' do
                  @cstring.list.should == ['self']
                end

                it 'list size is 1' do
                  @cstring.list.size.should be 1
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
        @attr.rm_attribute_name.should == 'members'
      end

      it 'existence are 0..1' do
        existence = OpenEHR::AssumedLibraryTypes::Interval.new(
                        :lower => 0, :upper => 1,
                        :lower_included => true, :upper_included => true)
        @attr.existence.should == existence
      end

      it 'cardinality interval is 0..8' do
        interval = OpenEHR::AssumedLibraryTypes::Interval.new(
                        :lower => 0, :upper => 8,
                        :lower_included => true, :upper_included => true)
        @attr.cardinality.interval.should == interval
      end

      it 'children size are 2' do
        @attr.children.size.should be 2
      end

      context '1st person' do
        before(:all) do
          @first = @attr.children[0]
        end

        it 'rm type name is PERSON' do
          @first.rm_type_name.should == 'PERSON'
        end

        it 'occurrences are default' do
          @first.occurrences.should == @occurrences
        end

        it 'attributes size is 1' do
          @first.attributes.size.should be 1
        end
      end

      context '2nd person' do
        before(:all) do
          @second = @attr.children[1]
        end

        it 'rm type name is PERSON' do
          @second.rm_type_name.should == 'PERSON'
        end

        it 'occurences is upper unbounded' do
          occurrences = OpenEHR::AssumedLibraryTypes::Interval.new(
                          :lower => 0, :lower_included => true)
          @second.occurrences.should == occurrences
        end

        
      end
    end
  end
end
