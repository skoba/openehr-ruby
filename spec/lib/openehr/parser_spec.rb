require File.dirname(__FILE__) + '/../../spec_helper'

describe OpenEHR::Parser::Base do
  describe 'SAFE_PARSE_OPTIONS' do
    subject(:options) { described_class::SAFE_PARSE_OPTIONS }

    it 'is an explicit Nokogiri XML parse-options object' do
      expect(options).to be_a(Nokogiri::XML::ParseOptions)
    end

    it 'preserves recovery while disabling entity and external DTD loading and network access' do
      expect(options).to be_recover
      expect(options).to be_nonet
      expect(options).not_to be_noent
      expect(options).not_to be_dtdload
    end

    it 'matches the currently resolved Nokogiri default XML option bits' do
      expect(options.to_i).to eq(Nokogiri::XML::ParseOptions::DEFAULT_XML)
    end
  end
end
