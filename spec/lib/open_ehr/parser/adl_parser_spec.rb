require File.dirname(__FILE__) + '/../../../spec_helper'
include OpenEHR::Parser
include OpenEHR::AM::Archetype::ConstraintModel
include OpenEHR::AM::Archetype::Assertion
include OpenEHR::AM::Archetype::Ontology

describe ADLParser do

  before (:all) do
    @adl_dir = File.dirname(__FILE__) + '/adl/'
  end

  context 'openEHR-EHR-SECTION-summary.v1.adl' do
    before(:all) do
      @ap = OpenEHR::Parser::ADLParser.new(@adl_dir + 'openEHR-EHR-SECTION.summary.v1.adl')
    end

    it 'is an instance fo ADLParser' do
      @ap.should be_an_instance_of ADLParser
    end

    context 'openEHR-EHR-SECTION.summary.v1 parse' do
      context 'ADL parser generates archetype from ADL' do
        before(:all) do
          @archetype = @ap.parse
        end

        it 'archetype_id should be openEHR-EHR-SECTION-summary' do
          @archetype.archetype_id.should == 'openEHR-EHR-SECTION.summary.v1'
        end

        it 'adl_version should be 1.4' do
          @archetype.adl_version.should == '1.4'
        end

        it 'concept should be at0000]' do
          @archetype.concept.should == 'at0000'
        end

        it 'original language is ISO_639-1::en' do
          @archetype.original_language.should == 'ISO_639-1::en'
        end

        context 'description' do
          before(:all) do
            @description = @archetype.description
          end

          context 'original author' do
            before(:all) do
              @original_author = @description[:original_author]
            end

            it 'name is Sam Heard' do
              @original_author[:name].should == 'Sam Heard'
            end

            it 'organisation is Ocean Informatics' do
              @original_author[:organisation].should == 'Ocean Informatics'
            end

            it 'date is 9/01/2007' do
              @original_author[:date].should == '9/01/2007'
            end

            it 'email is sam.heard@oceaninformatics.biz' do
              @original_author[:email].should == 'sam.heard@oceaninformatics.biz'
            end
          end

          context 'details' do
            before(:all) do
              @details = @description[:details]
            end

            context 'en details' do
              before(:all) do
                @en = @details[:en]
              end

              it 'language is ISO_639-1::en' do
                @en[:language].should == 'ISO_639-1::en'
              end 

              it 'purpose is A heading...' do
                @en[:purpose].should == "A heading containing summary information based on particular evaluation entries"
              end

              it 'use is A heading for...' do
                @en[:use].should == "A heading for organising clinical data under a heading of summary"
              end

              it 'keywords are review, conclusions, risk' do
                @en[:keywords].should == ['review', 'conclusions', 'risk']
              end

              it 'misuse should empty' do
                @en[:misuse].should == ''
              end
            end

            it 'lifecycle_state is Initial' do
              @description[:lifecycle_state].should == 'Initial'
            end

            it 'other_contributors is nil' do
              @description[:other_contributors].should be_nil
            end
          end # of details
        end # of description

        context 'definition section' do
          before(:all) do
            @definition = @archetype.definition
          end

          it 'rm_type is SECTION' do
            @definition.rm_type_name.should == 'SECTION'
          end

          it 'node_id is at0000' do
            @definition.node_id.should == 'at0000'
          end

          it 'root path is /' do
            @definition.path.should == '/'
          end

          it 'not any allowed' do
            @definition.any_allowed?.should == false
          end

          context 'c_attribute specs' do
            before(:all) do
              @attribute = @definition.attributes[0]
            end

            it 'attribute is instance of CMultipleAttribute' do
              @attribute.should be_an_instance_of CMultipleAttribute
            end

            it 'rm_attribute_name is items' do
              @attribute.rm_attribute_name.should == 'items'
            end

            it 'path is /items' do
              @attribute.path.should == '/items'
            end

            it 'cardinarity is unorderd' do
              @attribute.cardinality.should_not be_ordered
            end

            it 'lower interval of cardinality is 0' do
              @attribute.cardinality.interval.lower.should be 0
            end

            it 'interval of cardinality is upper unbounded' do
              @attribute.cardinality.interval.should be_upper_unbounded
            end
            context 'children archetype slot specs' do
              before(:all) do
                @archetype_slot = @attribute.children[0]
              end

              it 'is an instance of ArchetypeSlot' do
                @archetype_slot.should be_an_instance_of ArchetypeSlot
              end

              it 's rm type name is EVALUATION' do
                @archetype_slot.rm_type_name.should == 'EVALUATION'
              end

              it 's lower of occurrences should be 0' do
                @archetype_slot.occurrences.lower.should be 0
              end

              it 's upper of occurrences should be 1' do
                @archetype_slot.occurrences.upper.should be 1
              end

              context 'assertions' do
                before(:all) do
                  @includes = @archetype_slot.includes
                end

                context '1st assertion' do
                  before(:all) do
                    @assertion0 = @includes[0]
                  end

                  it 'assertion0 should be an instance of Assertion' do
                    @assertion0.should be_an_instance_of Assertion
                  end

                  it 'expression type of assertion0 is Boolean' do
                    @assertion0.expression.type.should == 'Boolean'
                  end

                  it 'expression value of assertion0 is /clinical_synopsis\.v1/' do
                    @assertion0.expression.item.pattern.should == '/clinical_synopsis\.v1/'
                  end
                end

                context '2nd assertion' do
                  before(:all) do
                    @assertion1 = @includes[1]
                  end

                  it 'assertion1 is an instanse of Assertion' do
                    @assertion1.should be_an_instance_of Assertion
                  end

                  it 'Assertion1 type is Boolean' do
                    @assertion1.expression.type.should == 'Boolean'
                  end

                  it 'expression value of assertion1 is /problem\.v1/' do
                    @assertion1.expression.item.pattern.should ==
                      '/problem\.v1/'
                  end
                end

                context '3rd assertion' do
                  before(:all) do
                    @assertion2 = @includes[2]
                  end

                  it 'assertion2 is an instanse of Assertion' do
                    @assertion2.should be_an_instance_of Assertion
                  end

                  it 'Assertion2 type is Boolean' do
                    @assertion2.expression.type.should == 'Boolean'
                  end

                  it 'expression value of Assertion2 is /problem\.v1/' do
                    @assertion2.expression.item.pattern.should ==
                      '/problem-diagnosis\.v1/'
                  end
                end

                context '4th assertion' do
                  before(:all) do
                    @assertion3 = @includes[3]
                  end

                  it 'assertion3 is an instanse of Assertion' do
                    @assertion3.should be_an_instance_of Assertion
                  end

                  it 'Assertion3 type is Boolean' do
                    @assertion3.expression.type.should == 'Boolean'
                  end

                  it 'expression value of assertion3 is /problem\.v1/' do
                    @assertion3.expression.item.pattern.should ==
                      '/problem-diagnosis-histological\.v1/'
                  end
                end

                context '5th assertion' do
                  before(:all) do
                    @assertion4 = @includes[4]
                  end

                  it 'assertion4 is an instanse of Assertion' do
                    @assertion4.should be_an_instance_of Assertion
                  end

                  it 'Assertion4 type is Boolean' do
                    @assertion4.expression.type.should == 'Boolean'
                  end

                  it 'expression value of assertion4 is /problem\.v1/' do
                    @assertion4.expression.item.pattern.should ==
                      '/problem-genetic\.v1/'
                  end
                end

                context '6th assertion' do
                  before(:all) do
                    @assertion5 = @includes[5]
                  end

                  it 'assertion5 is an instanse of Assertion' do
                    @assertion5.should be_an_instance_of Assertion
                  end

                  it 'Assertion5 type is Boolean' do
                    @assertion5.expression.type.should == 'Boolean'
                  end

                  it 'expression value of assertion5 is /problem\.v1/' do
                    @assertion5.expression.item.pattern.should ==
                      '/risk\.v1/'
                  end
                end

                context '7th assertion(is null)' do
                  it '7th assersion is nil' do
                    @includes[6].should be_nil
                  end
                end
              end
            end
          end
        end #definition

        context 'ontology section' do
          before(:all) do
            @archetype_ontology = @archetype.ontology
          end

          it 'is an ArchtypeOntology instance' do
            @archetype_ontology.should be_an_instance_of ArchetypeOntology
          end

        end
      end
    end
  end
end
