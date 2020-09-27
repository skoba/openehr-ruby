describe 'minimum_template' do
  let(:optparser) { OpenEHR::Parser::OPTParser.new(File.join(File.dirname(__FILE__), '/minimum_template.opt'))}
  let(:opt) {optparser.parse}

  MANDATORY =
    OpenEHR::AssumedLibraryTypes::Interval.new(lower: 1,
                                               upper: 1,
                                               lower_included: true,
                                               upper_included: true,
                                               upper_unbounded: false,
                                               lower_unbounded: false)
  OPTIONAL =
    OpenEHR::AssumedLibraryTypes::Interval.new(lower: 0,
                                               upper: 1,
                                               lower_included: true,
                                               upper_included: true,
                                               upper_unbounded: false,
                                               lower_unbounded: false)

    MORE_THAN_ZERO =
      OpenEHR::AssumedLibraryTypes::Interval.new(lower: 0,
                                               lower_included: true,
                                               upper_unbounded: true,
                                               lower_unbounded: false)

  
  it 'concept is minimum template' do
    expect(opt.concept).to eq 'minimum template'
  end

  it 'template_id is minimum template' do
    expect(opt.template_id.value).to eq 'minimum template'
  end

  it 'template uid is assigned' do
    expect(opt.uid.value).to eq '199f6890-5c06-4cb2-92de-422848ffe3a8'
  end

  it 'language is ja' do
    expect(opt.language.code_string).to eq 'ja'
  end

  describe 'description' do
    let(:description) { opt.description }

    specify 'original author' do
      expect(description.original_author).
        to eq 'Not Specified'
    end

    specify 'lifecycle state' do
      expect(description.lifecycle_state).
        to eq 'Initial'
    end

    context 'other_details' do
      let(:other_details) { description.other_details }

      specify 'MetaDataset:Sampleset' do
        expect(other_details['MetaDataSet:Sample Set ']).
          to eq 'Template metadata sample set '
      end

      specify 'empty data' do
        empty_details = ['Acknowledgements',
                         'Business Process Level',
                         'Care setting',
                         'Client group',
                         'Clinical Record Element',
                         'Copyright', 'Issues',
                         'Owner',
                         'Sign off',
                         'Speciality',
                         'User roles']
        empty_details.each do |d|
          expect(other_details[d]).to eq ''
        end
      end
    end
  end

  describe 'definiition' do
    it 'definition root is COMPOSITION' do
      expect(opt.definition.rm_type_name).to eq 'COMPOSITION'
    end
    
    it 'node_id is at0000' do
      expect(opt.definition.node_id).to eq 'at0000'
    end

    it 'root path is /' do
      expect(opt.definition.path).to eq '/'
    end

    specify 'occurrence is 1..1' do
      expect(opt.definition.occurrences).to eq MANDATORY
    end

    describe 'attributes' do
      let(:attributes) { opt.definition.attributes }
      
      specify 'attributes size is 3' do
        expect(attributes.size).to eq 3
      end

      describe '1st attribute' do
        let(:category) { attributes[0] }

        specify 'type' do
          expect(category).to be_an_instance_of OpenEHR::AM::Archetype::ConstraintModel::CSingleAttribute
        end

        specify 'rm_attribute_name is category' do
          expect(category.rm_attribute_name).to eq 'category'
        end

        specify 'existence is 1..1' do
          expect(category.existence).to eq MANDATORY
        end

        describe 'children' do
          specify 'only one child' do
            expect(category.children.size).to eq 1
          end

          describe 'child' do
            let(:child) { category.children[0] }

            specify 'rm_type_name is DV_CODED_TEXT' do
              expect(child.rm_type_name).to eq 'DV_CODED_TEXT'
            end

            specify 'occurrences is 1..1' do
              expect(child.occurrences).to eq MANDATORY
            end

            describe 'attribute defining code' do
              let(:type) { child.attributes[0] }

              specify 'type' do
                expect(type).to be_an_instance_of OpenEHR::AM::Archetype::ConstraintModel::CSingleAttribute
              end

            end
          end
        end
      end


      describe '2nd attribute' do
        let(:context) { attributes[1] }

        specify 'class' do
          expect(context).
            to be_an_instance_of OpenEHR::AM::Archetype::ConstraintModel::CSingleAttribute
        end

        specify 'name' do
          expect(context.rm_attribute_name).
            to eq 'context'
        end

        specify 'context' do
          expect(context.existence).to eq OPTIONAL
        end

        context 'children' do
          specify 'size' do
            expect(context.children.size).to eq 1
          end

          let(:child2_1) { context.children[0] }

          specify 'class' do
            expect(child2_1).to be_an_instance_of OpenEHR::AM::Archetype::ConstraintModel::CComplexObject
          end

          specify 'rm_type_name' do
            expect(child2_1.rm_type_name).
              to eq 'EVENT_CONTEXT'
          end

          specify 'occurrence' do
            expect(child2_1.occurrences).
              to eq MANDATORY
          end

          example 'node_id taken over form the parent' do
            expect(child2_1.node_id).to eq 'at0000'
          end

          context 'attributes' do
            specify 'size' do
              expect(child2_1.attributes.size).to eq 1
            end

            let(:other_context) { child2_1.attributes[0] }

            specify 'class' do
              expect(other_context).
                to be_an_instance_of OpenEHR::AM::Archetype::ConstraintModel::CSingleAttribute
            end

            specify 'rm_attribute_name' do
              expect(other_context.rm_attribute_name).
                to eq 'other_context'
            end

            specify 'existence' do
              expect(other_context.existence).to eq OPTIONAL
            end

            context 'children' do
              specify 'size' do
                expect(other_context.children.size).to eq 1
              end

              let(:oc0) { other_context.children[0] }

              specify 'class' do
                expect(oc0).to be_an_instance_of OpenEHR::AM::Archetype::ConstraintModel::CComplexObject
              end

              specify 'rm_type_name' do
                expect(oc0.rm_type_name).to eq 'ITEM_TREE'
              end

              specify 'occurrences' do
                expect(oc0.occurrences).to eq MANDATORY
              end

              specify 'node_id' do
                expect(oc0.node_id).to eq 'at0001'
              end

              context 'attributes' do
                specify 'size' do
                  expect(oc0.attributes.size).to eq 1
                end

                let(:items) { oc0.attributes[0] }

                context 'cardinality' do
                  specify 'order' do
                    expect(items.cardinality).not_to be_ordered
                  end

                  specify 'is_ordered' do
                    expect(items.cardinality.is_ordered?).to be_falsy
                  end

                  specify 'unique' do
                    expect(items.cardinality).not_to be_unique
                  end

                  specify 'is_unique' do
                    expect(items.cardinality.is_unique?).to be_falsy
                  end
                end

                specify 'rm_attribute_name' do
                  expect(items.rm_attribute_name).to eq 'items'
                end

                specify 'existence' do
                  expect(items.existence).to eq OPTIONAL
                end
                
                context 'children' do
                  specify 'size' do
                    expect(items.children.size).to eq 1
                  end

                  let(:child) { items.children[0] }

                  specify 'rm_type_name' do
                    expect(child.rm_type_name).
                      to eq 'ELEMENT'
                  end

                  specify 'path' do
                    expect(child.path).to eq '/context/other_context[at0001]/items[at0002]'
                  end

                  specify 'occurrences' do
                    expect(child.occurrences).to eq OPTIONAL
                  end

                  specify 'node_id' do
                    expect(child.node_id).to eq 'at0002'
                  end

                  context 'attributes' do
                    specify 'size' do
                      expect(child.attributes.size).
                        to eq 2
                    end

                    context 'attribute' do
                      let(:value) { child.attributes[0] }

                      specify 'rm_attribute_name' do
                        expect(value.rm_attribute_name).
                          to eq 'value'
                      end

                      specify 'existence' do
                        expect(value.existence).
                          to eq OPTIONAL
                      end

                      context 'children' do
                        specify 'size' do
                          expect(value.children.size).
                            to eq 1
                        end

                        let(:dv_text) { value.children[0] }

                        specify 'class' do
                          expect(dv_text).
                            to be_an_instance_of OpenEHR::AM::Archetype::ConstraintModel::CComplexObject
                        end

                        specify 'rm_type_name' do
                          expect(dv_text.rm_type_name).
                            to eq 'DV_TEXT'
                        end

                        specify 'occurrence' do
                          expect(dv_text.occurrences).
                            to eq MANDATORY
                        end

                        specify 'node id' do
                          expect(dv_text.node_id).
                            to eq 'at0002'
                        end
                      end
                    end

                    context '2nd attribute' do
                      let(:name) { child.attributes[1] }

                      specify 'class' do
                        expect(name).
                          to be_an_instance_of OpenEHR::AM::Archetype::ConstraintModel::CSingleAttribute
                      end

                      specify 'rm_attribute_name' do
                        expect(name.rm_attribute_name).
                          to eq 'name'
                      end

                      specify 'existence' do
                        expect(name.existence).
                          to eq MANDATORY
                      end

                      context 'children' do
                        specify 'size' do
                          expect(name.children.size).to eq 1
                        end

                        let(:value_t) { name.children[0] }

                        specify 'class' do
                          expect(value_t).
                            to be_an_instance_of OpenEHR::AM::Archetype::ConstraintModel::CComplexObject
                        end

                        specify 'rm_type_name' do
                          expect(value_t.rm_type_name).
                            to eq 'DV_TEXT'
                        end

                        specify 'occurrences' do
                          expect(value_t.occurrences).
                            to eq MANDATORY
                        end

                        specify 'node_id' do
                          expect(value_t.node_id).
                            to eq 'at0002'
                        end

                        context 'attributes' do
                          specify 'size' do
                            expect(value_t.attributes.size).
                              to eq 1
                          end

                          let(:value_2) { value_t.attributes[0] }
                          specify 'type' do
                            expect(value_2).
                              to be_an_instance_of OpenEHR::AM::Archetype::ConstraintModel::CSingleAttribute
                          end

                          specify 'rm_attribute_name' do
                            expect(value_2.rm_attribute_name).
                              to eq 'value'
                          end
                          specify 'existence' do
                            expect(value_2.existence).
                              to eq MANDATORY
                          end

                          context 'children' do
                            specify 'size' do
                              expect(value_2.children.size).
                                to eq 1
                            end

                            let(:prim) { value_2.children[0] }

                            specify 'class' do
                              expect(prim).
                                to be_an_instance_of OpenEHR::AM::Archetype::ConstraintModel::CPrimitiveObject
                            end

                            specify 'type' do
                              expect(prim.rm_type_name).
                                to eq 'STRING'
                            end

                            specify 'occurrences' do
                              expect(prim.occurrences).
                                to eq MANDATORY
                            end

                            specify 'node_id' do
                              expect(prim.node_id).
                                to eq 'at0002'
                            end

                            specify 'item' do
                              expect(prim.item).
                                to be_an_instance_of OpenEHR::AM::Archetype::ConstraintModel::Primitive::CString
                            end

                            specify 'list' do
                              expect(prim.item.list).
                                to eq %w(Title)
                            end
                          end
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end

      describe '3rd attribute, content' do
        let(:content) { attributes[2] }

        specify 'type' do
          expect(content).to be_an_instance_of OpenEHR::AM::Archetype::ConstraintModel::CMultipleAttribute
        end

        specify 'rm_attribute_name' do
          expect(content.rm_attribute_name).to eq 'content'
        end

        specify 'existence' do
          expect(content.existence).to eq OPTIONAL
        end

        specify 'cardinality'

        context 'children' do
          specify 'size' do
            expect(content.children.size).to eq 1
          end

          let(:section) { content.children[0] }

          specify 'type' do
            expect(section).to be_an_instance_of OpenEHR::AM::Archetype::ConstraintModel::CArchetypeRoot
          end

          specify 'rm_type_name' do
            expect(section.rm_type_name).to eq 'SECTION'
          end

          specify 'occurrences' do
            expect(section.occurrences).to eq MORE_THAN_ZERO
          end

          specify 'node_id' do
            expect(section.node_id).to eq 'at0000'
          end

          context 'attributes' do
            specify 'size' do
              expect(section.attributes.size).to eq 1
            end

            context 'items' do
              let(:items_attribute) { section.attributes[0] }
              specify 'type' do
                expect(items_attribute).to be_an_instance_of OpenEHR::AM::Archetype::ConstraintModel::CMultipleAttribute
              end

              specify 'rm_attribute_name' do
                expect(items_attribute.rm_attribute_name).
                  to eq 'items'
              end

              specify 'existence' do
                expect(items_attribute.existence).
                  to eq OPTIONAL
              end

              context 'children' do
                specify 'size' do
                  expect(items_attribute.children.size).
                    to eq 1
                end

                let(:evaluation) { items_attribute.children[0] }

                specify 'type' do
                  expect(evaluation).
                    to be_an_instance_of OpenEHR::AM::Archetype::ConstraintModel::CArchetypeRoot
                end

                specify 'rm_type_name' do
                  expect(evaluation.rm_type_name).
                    to eq 'EVALUATION'
                end

                specify 'occurrences' do
                  expect(evaluation.occurrences).
                    to eq MORE_THAN_ZERO
                end

                specify 'node_id' do
                  expect(evaluation.node_id).to eq 'at0000'
                end
              end
            end
          end
        end
      end
    end
  end

  describe 'component_terminologies' do
    context 'root component' do
      it 'component_terminologies are hash of archetype and terminologies' do
        expect(opt.component_terminologies).to have_key 'openEHR-EHR-COMPOSITION.minimum.v1'
      end

      context 'minimum term_definitions' do
        let(:term_definitions) { opt.component_terminologies['openEHR-EHR-COMPOSITION.minimum.v1'].term_definitions['ja']}

        it 'archetype have 3 items' do
          expect(term_definitions).to have(3).items
        end

        it 'is an array' do
          expect(term_definitions).to be_an_instance_of Array
        end

        it 'is included an instance of ArchetypeTerm' do
          expect(term_definitions).to include an_instance_of OpenEHR::AM::Archetype::Terminology::ArchetypeTerm
        end

        it 'is expected to contain valid codes' do
          codes = term_definitions.map{|term| term.code}
          expect(codes).to contain_exactly 'at0000', 'at0001', 'at0002'
        end

        context 'at0000 term' do
          let(:term) { term_definitions[0] }

          it 'code is at0000' do
            expect(term.code).to eq 'at0000'
          end

          it 'item has text' do
            expect(term.items).to have_key 'text'
          end

          it 'text associate Minimum' do
            expect(term.items['text']).to eq 'Minimum'
          end

          it 'description associate mimimum set for ' do
            expect(term.items['description']).to eq 'minimum set for '
          end
        end
      end

      context 'problem diagnosis term_definitions' do
        let(:term_definitions) {opt.component_terminologies['openEHR-EHR-EVALUATION.problem_diagnosis.v1'].term_definitions['ja']}

        it 'has 25 items' do
          expect(term_definitions).to have(27).items
        end
      end
    end
  end
end
