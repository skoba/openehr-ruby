require File.dirname(__FILE__) + '/../../../spec_helper'

describe OpenEHR::Parser::ADLParser do

  before (:all) do
    @adl_dir = File.dirname(__FILE__) + '/adl14/'
  end

  context 'openEHR-EHR-SECTION-summary.v1.adl' do
    before(:all) do
      @ap = OpenEHR::Parser::ADLParser.new(@adl_dir + 'openEHR-EHR-SECTION.summary.v1.adl')
    end

    it 'is an instance fo ADLParser' do
      expect(@ap).to be_an_instance_of OpenEHR::Parser::ADLParser
    end

    context 'openEHR-EHR-SECTION.summary.v1 parse' do
      context 'ADL parser generates archetype from ADL' do
        before(:all) do
          @archetype = @ap.parse
        end

        it 'archetype is an instance of Archetype' do
          expect(@archetype).to be_an_instance_of OpenEHR::AM::Archetype::Archetype
        end

        it 'archetype_id should be openEHR-EHR-SECTION-summary' do
          expect(@archetype.archetype_id.value).to eq( 
            'openEHR-EHR-SECTION.summary.v1'
          )
        end

        it 'adl_version should be 1.4' do
          expect(@archetype.adl_version).to eq('1.4')
        end

        it 'concept should be at0000' do
          expect(@archetype.concept).to eq('at0000')
        end

        it 'original language is en' do
          expect(@archetype.original_language.code_string).to eq('en')
        end

        context 'description' do
          before(:all) do
            @description = @archetype.description
          end

          context 'original author' do
            before(:all) do
              @original_author = @description.original_author
            end

            it 'name is Sam Heard' do
              expect(@original_author['name']).to eq('Sam Heard')
            end

            it 'organisation is Ocean Informatics' do
              expect(@original_author['organisation']).to eq('Ocean Informatics')
            end

            it 'date is 9/01/2007' do
              expect(@original_author['date']).to eq('9/01/2007')
            end

            it 'email is sam.heard@oceaninformatics.biz' do
              expect(@original_author['email']).to eq('sam.heard@oceaninformatics.biz')
            end
          end

          context 'details' do
            before(:all) do
              @details = @description.details
            end

            context 'en details' do
              before(:all) do
                @en = @details['en']
              end

              it 'language is en' do
                expect(@en.language.code_string).to eq('en')
              end 

              it 'purpose is A heading...' do
                expect(@en.purpose).to eq("A heading containing summary information based on particular evaluation entries")
              end

              it 'use is A heading for...' do
                expect(@en.use).to eq("A heading for organising clinical data under a heading of summary")
              end

              it 'keywords are review, conclusions, risk' do
                expect(@en.keywords).to eq(['review', 'conclusions', 'risk'])
              end

              it 'misuse should be nil' do
                expect(@en.misuse).to be_nil
              end
            end

            it 'lifecycle_state is Initial' do
              expect(@description.lifecycle_state).to eq('Initial')
            end

            it 'other_contributors is nil' do
              expect(@description.other_contributors).to be_nil
            end
          end # of details
        end # of description

        context 'definition section' do
          before(:all) do
            @definition = @archetype.definition
          end

          it 'rm_type is SECTION' do
            expect(@definition.rm_type_name).to eq('SECTION')
          end

          it 'node_id is at0000' do
            expect(@definition.node_id).to eq('at0000')
          end

          it 'root path is /' do
            expect(@definition.path).to eq('/')
          end

          it 'not any allowed' do
            expect(@definition.any_allowed?).to eq(false)
          end

          context 'c_attribute specs' do
            before(:all) do
              @attribute = @definition.attributes[0]
            end

            it 'attribute is instance of CMultipleAttribute' do
              expect(@attribute).to be_an_instance_of OpenEHR::AM::Archetype::ConstraintModel::CMultipleAttribute
            end

            it 'rm_attribute_name is items' do
              expect(@attribute.rm_attribute_name).to eq('items')
            end

            it 'path is /items' do
              expect(@attribute.path).to eq('/items')
            end

            it 'cardinarity is unorderd' do
              expect(@attribute.cardinality).not_to be_ordered
            end

            it 'lower interval of cardinality is 0' do
              expect(@attribute.cardinality.interval.lower).to be 0
            end

            it 'interval of cardinality is upper unbounded' do
              expect(@attribute.cardinality.interval).to be_upper_unbounded
            end
            context 'children archetype slot specs' do
              before(:all) do
                @archetype_slot = @attribute.children[0]
              end

              it 'is an instance of ArchetypeSlot' do
                expect(@archetype_slot).to be_an_instance_of OpenEHR::AM::Archetype::ConstraintModel::ArchetypeSlot
              end

              it 's rm type name is EVALUATION' do
                expect(@archetype_slot.rm_type_name).to eq('EVALUATION')
              end

              it 's lower of occurrences should be 0' do
                expect(@archetype_slot.occurrences.lower).to be 0
              end

              it 's upper of occurrences should be 1' do
                expect(@archetype_slot.occurrences.upper).to be 1
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
                    expect(@assertion0).to be_an_instance_of OpenEHR::AM::Archetype::Assertion::Assertion
                  end

                  it 'expression type of assertion0 is Boolean' do
                    expect(@assertion0.expression.type).to eq('Boolean')
                  end

                  it 'expression value of assertion0 is /clinical_synopsis\.v1/' do
                    expect(@assertion0.expression.right_operand.item.pattern).to eq('/clinical_synopsis\.v1/')
                  end
                end

                context '2nd assertion' do
                  before(:all) do
                    @assertion1 = @includes[1]
                  end

                  it 'assertion1 is an instanse of Assertion' do
                    expect(@assertion1).to be_an_instance_of OpenEHR::AM::Archetype::Assertion::Assertion
                  end

                  it 'Assertion1 type is Boolean' do
                    expect(@assertion1.expression.type).to eq('Boolean')
                  end

                  it 'expression value of assertion1 is /problem\.v1/' do
                    expect(@assertion1.expression.right_operand.item.pattern).to eq(
                      '/problem\.v1/'
                    )
                  end
                end

                context '3rd assertion' do
                  before(:all) do
                    @assertion2 = @includes[2]
                  end

                  it 'assertion2 is an instanse of Assertion' do
                    expect(@assertion2).to be_an_instance_of OpenEHR::AM::Archetype::Assertion::Assertion
                  end

                  it 'Assertion2 type is Boolean' do
                    expect(@assertion2.expression.type).to eq('Boolean')
                  end

                  it 'expression value of Assertion2 is /problem\.v1/' do
                    expect(@assertion2.expression.right_operand.item.pattern).to eq(
                      '/problem-diagnosis\.v1/'
                    )
                  end
                end

                context '4th assertion' do
                  before(:all) do
                    @assertion3 = @includes[3]
                  end

                  it 'assertion3 is an instanse of Assertion' do
                    expect(@assertion3).to be_an_instance_of OpenEHR::AM::Archetype::Assertion::Assertion
                  end

                  it 'Assertion3 type is Boolean' do
                    expect(@assertion3.expression.type).to eq('Boolean')
                  end

                  it 'expression value of assertion3 is /problem\.v1/' do
                    expect(@assertion3.expression.right_operand.item.pattern).to eq(
                      '/problem-diagnosis-histological\.v1/'
                    )
                  end
                end

                context '5th assertion' do
                  before(:all) do
                    @assertion4 = @includes[4]
                  end

                  it 'assertion4 is an instanse of Assertion' do
                    expect(@assertion4).to be_an_instance_of OpenEHR::AM::Archetype::Assertion::Assertion
                  end

                  it 'Assertion4 type is Boolean' do
                    expect(@assertion4.expression.type).to eq('Boolean')
                  end

                  it 'expression value of assertion4 is /problem\.v1/' do
                    expect(@assertion4.expression.right_operand.item.pattern).to eq(
                      '/problem-genetic\.v1/'
                    )
                  end
                end

                context '6th assertion' do
                  before(:all) do
                    @assertion5 = @includes[5]
                  end

                  it 'assertion5 is an instanse of Assertion' do
                    expect(@assertion5).to be_an_instance_of OpenEHR::AM::Archetype::Assertion::Assertion
                  end

                  it 'Assertion5 type is Boolean' do
                    expect(@assertion5.expression.type).to eq('Boolean')
                  end

                  it 'expression value of assertion5 is /problem\.v1/' do
                    expect(@assertion5.expression.right_operand.item.pattern).to eq(
                      '/risk\.v1/'
                    )
                  end
                end

                context '7th assertion(is null)' do
                  it '7th assersion is nil' do
                    expect(@includes[6]).to be_nil
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
            expect(@archetype_ontology).to be_an_instance_of OpenEHR::AM::Archetype::Ontology::ArchetypeOntology
          end

          it 'term_definitions parsed and assigned properly' do
            expect(@archetype_ontology.term_definition(:lang => 'en',
               :code => 'at0000').items['text']).to eq('Summary')
          end

          it 'description term_definitions parsed and assigned properly' do
            expect(@archetype_ontology.term_definition(:lang => 'en',
               :code => 'at0000').items['description']).to eq(
                 'A heading for conclusions and other evaluations'
            )
          end

          it 'term_codes should be assigned properly' do
            expect(@archetype_ontology.term_codes).to eq(['at0000'])
          end

          it 'ArchetypeOntology has en lang' do
            expect(@archetype_ontology).to have_language 'en'
          end
        end
      end
    end
  end
end
