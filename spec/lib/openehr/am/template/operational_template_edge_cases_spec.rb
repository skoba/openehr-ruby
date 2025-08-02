require 'spec_helper'

module OpenEHR
  module AM
    module Template
      describe OperationalTemplate do
        let(:term_id) { OpenEHR::RM::Support::Identification::TerminologyID.new(value: 'ISO_639-1') }
        let(:language) { OpenEHR::RM::DataTypes::Text::CodePhrase.new(terminology_id: term_id, code_string: 'en') }
        let(:template_id) { OpenEHR::RM::Support::Identification::TemplateID.new(value: 'test.template.v1') }
        let(:description) { double('ResourceDescription') }
        let(:definition) { double('C_ARCHETYPE_ROOT', rm_type_name: 'COMPOSITION', node_id: 'at0000') }
        let(:ontology) { double('ArchetypeTerminology', concept_code: 'at0000', original_language: language) }

        describe 'error handling and validation' do
          context 'invalid initialization parameters' do
            it 'should raise error when template_id is nil' do
              expect {
                OperationalTemplate.new(
                  template_id: nil,
                  original_language: language,
                  description: description,
                  definition: definition,
                  ontology: ontology
                )
              }.to raise_error(ArgumentError, 'template_id is mandatory for operational template')
            end

            it 'should raise error when definition is nil' do
              expect {
                OperationalTemplate.new(
                  template_id: template_id,
                  original_language: language,
                  description: description,
                  definition: nil,
                  ontology: ontology
                )
              }.to raise_error(ArgumentError, 'definition is mandatory')
            end

            it 'should raise error when description is nil' do
              expect {
                OperationalTemplate.new(
                  template_id: template_id,
                  original_language: language,
                  description: nil,
                  definition: definition,
                  ontology: ontology
                )
              }.to raise_error(ArgumentError, 'description is mandatory')
            end

            it 'should raise error when original_language is nil' do
              expect {
                OperationalTemplate.new(
                  template_id: template_id,
                  original_language: nil,
                  description: description,
                  definition: definition,
                  ontology: ontology
                )
              }.to raise_error(ArgumentError, 'original language is mandatory')
            end

            it 'should raise error when ontology is nil' do
              expect {
                OperationalTemplate.new(
                  template_id: template_id,
                  original_language: language,
                  description: description,
                  definition: definition,
                  ontology: nil
                )
              }.to raise_error(ArgumentError, 'ontology is mandatory')
            end
          end

          context 'validation methods' do
            subject do
              OperationalTemplate.new(
                template_id: template_id,
                original_language: language,
                description: description,
                definition: definition,
                ontology: ontology,
                adl_version: '1.4'
              )
            end

            describe '#is_valid_operational_template?' do
              it 'should be valid with all required attributes' do
                expect(subject.is_valid_operational_template?).to be true
              end

              context 'when template_id is missing' do
                before { subject.instance_variable_set(:@template_id, nil) }
                
                it 'should be invalid' do
                  expect(subject.is_valid_operational_template?).to be false
                end
              end

              context 'when definition is missing' do
                before { subject.instance_variable_set(:@definition, nil) }
                
                it 'should be invalid' do
                  expect(subject.is_valid_operational_template?).to be false
                end
              end

              context 'when component_terminologies is missing' do
                before { subject.instance_variable_set(:@component_terminologies, nil) }
                
                it 'should be invalid' do
                  expect(subject.is_valid_operational_template?).to be false
                end
              end
            end

            describe '#is_specialized?' do
              context 'with parent archetype id' do
                before { subject.parent_archetype_id = double('parent_id') }
                
                it 'should return true' do
                  expect(subject.is_specialized?).to be true
                end
              end

              context 'without parent archetype id' do
                it 'should return false' do
                  expect(subject.is_specialized?).to be false
                end
              end
            end

            describe '#referenced_archetype_ids' do
              context 'with empty component terminologies' do
                it 'should return empty array' do
                  expect(subject.referenced_archetype_ids).to eq([])
                end
              end

              context 'with component terminologies' do
                let(:component_terminologies) do
                  {
                    'archetype1.v1' => double('terminology1'),
                    'archetype2.v1' => double('terminology2')
                  }
                end

                subject do
                  OperationalTemplate.new(
                    template_id: template_id,
                    original_language: language,
                    description: description,
                    definition: definition,
                    ontology: ontology,
                    component_terminologies: component_terminologies,
                    adl_version: '1.4'
                  )
                end

                it 'should return archetype ids' do
                  expect(subject.referenced_archetype_ids).to contain_exactly('archetype1.v1', 'archetype2.v1')
                end
              end
            end

            describe '#terminology_for_archetype' do
              let(:terminology1) { double('terminology1') }
              let(:terminology2) { double('terminology2') }
              let(:component_terminologies) do
                {
                  'archetype1.v1' => terminology1,
                  'archetype2.v1' => terminology2
                }
              end

              subject do
                OperationalTemplate.new(
                  template_id: template_id,
                  original_language: language,
                  description: description,
                  definition: definition,
                  ontology: ontology,
                  component_terminologies: component_terminologies,
                  adl_version: '1.4'
                )
              end

              it 'should return correct terminology for existing archetype' do
                expect(subject.terminology_for_archetype('archetype1.v1')).to eq(terminology1)
                expect(subject.terminology_for_archetype('archetype2.v1')).to eq(terminology2)
              end

              it 'should return nil for non-existing archetype' do
                expect(subject.terminology_for_archetype('non.existing.v1')).to be_nil
              end
            end

            describe '#concept' do
              context 'with explicit concept' do
                subject do
                  OperationalTemplate.new(
                    template_id: template_id,
                    original_language: language,
                    description: description,
                    definition: definition,
                    ontology: ontology,
                    concept: 'Explicit Concept',
                    adl_version: '1.4'
                  )
                end

                it 'should return explicit concept' do
                  expect(subject.concept).to eq('Explicit Concept')
                end
              end

              context 'without explicit concept but with archetype_id' do
                let(:archetype_id_with_concept) { double('archetype_id', concept_name: 'ID Concept') }
                
                subject do
                  template = OperationalTemplate.new(
                    template_id: template_id,
                    original_language: language,
                    description: description,
                    definition: definition,
                    ontology: ontology,
                    adl_version: '1.4'
                  )
                  template.instance_variable_set(:@archetype_id, archetype_id_with_concept)
                  template
                end

                it 'should fallback to archetype_id concept_name' do
                  expect(subject.concept).to eq('ID Concept')
                end
              end

              context 'without explicit concept and without archetype_id' do
                subject do
                  template = OperationalTemplate.new(
                    template_id: template_id,
                    original_language: language,
                    description: description,
                    definition: definition,
                    ontology: ontology,
                    adl_version: '1.4'
                  )
                  template.instance_variable_set(:@archetype_id, nil)
                  template
                end

                it 'should return nil' do
                  expect(subject.concept).to be_nil
                end
              end
            end
          end

          context 'setter methods' do
            subject do
              OperationalTemplate.new(
                template_id: template_id,
                original_language: language,
                description: description,
                definition: definition,
                ontology: ontology,
                adl_version: '1.4'
              )
            end

            describe '#component_terminologies=' do
              it 'should accept hash' do
                terminologies = {'test.v1' => double('terminology')}
                subject.component_terminologies = terminologies
                expect(subject.component_terminologies).to eq(terminologies)
              end

              it 'should accept nil and convert to empty hash' do
                subject.component_terminologies = nil
                expect(subject.component_terminologies).to eq({})
              end
            end

            describe '#terminology_extracts=' do
              it 'should accept hash' do
                extracts = {'test.v1' => double('extract')}
                subject.terminology_extracts = extracts
                expect(subject.terminology_extracts).to eq(extracts)
              end

              it 'should accept nil and convert to empty hash' do
                subject.terminology_extracts = nil
                expect(subject.terminology_extracts).to eq({})
              end
            end

            describe '#language=' do
              it 'should set original_language' do
                new_language = OpenEHR::RM::DataTypes::Text::CodePhrase.new(
                  terminology_id: OpenEHR::RM::Support::Identification::TerminologyID.new(value: 'ISO_639-1'),
                  code_string: 'de'
                )
                subject.language = new_language
                expect(subject.original_language).to eq(new_language)
                expect(subject.language).to eq(new_language)
              end
            end
          end

          context 'archetype inheritance' do
            subject do
              OperationalTemplate.new(
                template_id: template_id,
                original_language: language,
                description: description,
                definition: definition,
                ontology: ontology,
                adl_version: '1.4'
              )
            end

            it 'should inherit all archetype methods' do
              expect(subject).to respond_to(:archetype_id)
              expect(subject).to respond_to(:definition)
              expect(subject).to respond_to(:original_language)
              expect(subject).to respond_to(:description)
              expect(subject).to respond_to(:ontology)
              expect(subject).to respond_to(:adl_version)
              expect(subject).to respond_to(:uid)
              expect(subject).to respond_to(:parent_archetype_id)
              expect(subject).to respond_to(:invariants)
            end

            it 'should have archetype_id set to template_id' do
              expect(subject.archetype_id).to eq(template_id)
            end

            it 'should respond to archetype validation methods' do
              expect(subject).to respond_to(:languages_available)
              expect(subject).to respond_to(:is_controlled?)
            end
          end
        end
      end
    end
  end
end