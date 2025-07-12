require 'spec_helper'

module OpenEHR
  module AM
    module Template
      describe OperationalTemplate do
        let(:term_id) { OpenEHR::RM::Support::Identification::TerminologyID.new(value: 'ISO_639-1') }
        let(:language) { OpenEHR::RM::DataTypes::Text::CodePhrase.new(terminology_id: term_id, code_string: 'en') }
        let(:details) { double('details', :size => 3, :nil? => false, :empty? => false) }
        let(:description) { OpenEHR::RM::Common::Resource::ResourceDescription.new(original_author: 'Shinji KOBAYASHI', lifecycle_state: 'Testing', details: details) }
        let(:template_id) { OpenEHR::RM::Support::Identification::TemplateID.new(value: '1234567890') }
        let(:definition) { double(OpenEHR::AM::Archetype::ConstraintModel::CArchetypeRoot, node_id: 'at0001') }
        let(:archetype_terminology) { double(OpenEHR::AM::Archetype::Terminology::ArchetypeTerminology, concept: 'minimum_template')}
        let(:component_terminologies) { Hash['openEHR-EHR-sample.v1' => archetype_terminology] }
        let(:ontology) { double(OpenEHR::AM::Archetype::Terminology::ArchetypeTerminology, :concept_code => 'at0000', :original_language => language) }
        let(:opt) { OpenEHR::AM::Template::OperationalTemplate.new(concept: 'Sample', original_language: language, description: description, template_id: template_id, definition: definition, component_terminologies: component_terminologies, ontology: ontology, adl_version: '1.4') }

        it 'should be an instance of OperationalTemplate' do
          expect(opt).to be_an_instance_of OpenEHR::AM::Template::OperationalTemplate
        end

        it 'template_id should be 1234567890' do
          expect(opt.template_id.value).to eq '1234567890'
        end

        it 'concept expected to Sample' do
          expect(opt.concept).to eq 'Sample'
        end

        it 'language code string is en' do
          expect(opt.language.code_string).to eq 'en'
        end

        it 'original author' do
          expect(opt.description.original_author).to eq 'Shinji KOBAYASHI'
        end

        it 'lifecycle state should be properly assigned' do
          expect(opt.description.lifecycle_state).to eq 'Testing'
        end

        it 'size of details is 3' do
          expect(opt.description.details.size).to eq 3
        end

        it 'definition root node is at0001' do
          expect(opt.definition.node_id).to eq 'at0001'
        end

        it 'component terminologies has key' do
          expect(opt.component_terminologies).to have_key 'openEHR-EHR-sample.v1'
        end

        # Test openEHR specification compliance
        context 'openEHR specification compliance' do
          it 'should inherit from Archetype' do
            expect(opt).to be_a(OpenEHR::AM::Archetype::Archetype)
          end

          it 'should have archetype_id matching template_id' do
            expect(opt.archetype_id).to eq(template_id)
          end

          it 'should have terminology_extracts attribute' do
            expect(opt).to respond_to(:terminology_extracts)
            expect(opt.terminology_extracts).to be_a(Hash)
          end

          it 'should be a valid operational template' do
            expect(opt.is_valid_operational_template?).to be true
          end

          it 'should provide referenced archetype ids' do
            expect(opt.referenced_archetype_ids).to include('openEHR-EHR-sample.v1')
          end

          it 'should return terminology for specific archetype' do
            expect(opt.terminology_for_archetype('openEHR-EHR-sample.v1')).to eq(archetype_terminology)
          end

          it 'should have all required archetype attributes' do
            expect(opt).to respond_to(:archetype_id)
            expect(opt).to respond_to(:concept)
            expect(opt).to respond_to(:definition)
            expect(opt).to respond_to(:original_language)
            expect(opt).to respond_to(:description)
            expect(opt).to respond_to(:ontology)
          end

          it 'should provide backward compatibility with language method' do
            expect(opt.language).to eq(language)
            expect(opt.language.code_string).to eq('en')
          end
        end
      end
    end
  end
end
