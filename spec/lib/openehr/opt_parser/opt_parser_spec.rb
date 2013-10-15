require 'spec_helper'

module OpenEHR
  module Parser
    describe OPTParser do
      let(:optparser) { OpenEHR::Parser::OPTParser.new('./eReferral.opt')}
      let(:opt) {optparser.parse}

      # it 'language code string is en' do
      #   expect(opt.description.language.code_string).to eq 'en'
      # end
    end
  end
end
