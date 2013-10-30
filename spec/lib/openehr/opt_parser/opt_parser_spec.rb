require 'spec_helper'

module OpenEHR
  module Parser
    describe OPTParser do
      let(:optparser) { OpenEHR::Parser::OPTParser.new(File.join(File.dirname(__FILE__), './eReferral.opt'))}
      let(:opt) {optparser.parse}

      it 'concept expected to eRefarral' do
        expect(opt.concept).to eq 'eReferral'
      end

      it 'language code string is en' do
        expect(opt.language.code_string).to eq 'en'
      end

      it 'original_author is not specified' do
        expect(opt.description.original_author).to eq 'Not Specified'
      end

      it 'details language terminology is ISO 639-1' do
        expect(opt.description.details[0].language.terminology_id.value).to eq 'ISO_639-1'
      end

      it 'template_id expected to e5f533a2-7480-4b53-91f6-9b83433f36ab' do
        expect(opt.template_id.value).to eq 'e5f533a2-7480-4b53-91f6-9b83433f36ab'
      end
    end
  end
end
