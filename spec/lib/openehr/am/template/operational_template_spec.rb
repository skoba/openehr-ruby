require 'spec_helper'

module OpenEHR
  module AM
    module Template
      describe OperationalTemplate do
        let(:term_id) {OpenEHR::RM::Support::Identification::TerminologyID.new(value: 'ISO_639-1')}
        let(:language) {OpenEHR::RM::DataTypes::Text::CodePhrase.new(terminology_id: term_id, code_string: 'en')}
        let(:opt) {OpenEHR::AM::Template::OperationalTemplate.new(language: language)}
        it 'should be an instance of OperationalTemplate' do
          expect(opt).to be_an_instance_of OpenEHR::AM::Template::OperationalTemplate
        end

        it 'language code string is en' do
          expect(opt.language.code_string).to eq 'en'
        end
      end
    end
  end
end
