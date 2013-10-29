require 'spec_helper'

module OpenEHR
  module Parser
    describe OPTParser do
      let(:optparser) { OpenEHR::Parser::OPTParser.new(File.join(File.dirname(__FILE__), './eReferral.opt'))}
      let(:opt) {optparser.parse}

      it 'language code string is en' do
        expect(opt.language.code_string).to eq 'en'
      end

      it 'original_author is not specified' do
        expect(opt.description.original_author).to eq 'Not Specified'
      end
    end
  end
end
