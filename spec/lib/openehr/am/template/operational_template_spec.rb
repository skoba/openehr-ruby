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
         let(:archetype_terminology) { double(OpenEHR::AM::Archetype::Ontology::ArchetypeTerminology(concept: 'minimum_template'))}
        let(:component_terminologies) { Hash['openEHR-EHR-sample.v1' => archetype_terminology] }
        let(:opt) { OpenEHR::AM::Template::OperationalTemplate.new(concept: 'Sample', language: language, description: description, template_id: template_id, definition: definition, component_terminologies: component_terminologies) }

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
          expect(opt.component_terminogies).to have_key 'openEHR-EHR-sample.v1'
        end
      end
    end
  end
end
