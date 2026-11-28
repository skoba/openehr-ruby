# frozen_string_literal: true

require File.dirname(__FILE__) + '/../spec_helper'

# #157 (R-20261128-13), resolution shape (c) pin/hardening: every XML
# fixture under spec/ (*.opt and *.xml) is well-formed XML, so that a
# strict parser reads it too. The parsers themselves read with RECOVER
# (#36 kept it); this spec is about the fixtures, not the parsers.
# regression pin: all of them already parse under STRICT.
describe 'XML fixtures are well-formed (#157)' do
  def self.fixture_paths = Dir.glob(File.join(File.expand_path('../..', __dir__), 'spec', '**', '*.{opt,xml}'))

  let(:strict) do
    Nokogiri::XML::ParseOptions.new(Nokogiri::XML::ParseOptions::STRICT | Nokogiri::XML::ParseOptions::NONET)
  end

  it 'finds the XML fixtures' do
    expect(self.class.fixture_paths.size).to be >= 8
  end

  fixture_paths.each do |path|
    relative = path.delete_prefix("#{File.expand_path('../..', __dir__)}/")

    it "#{relative} parses under STRICT (regression pin)" do
      expect { Nokogiri::XML::Document.parse(File.read(path), nil, nil, strict) }.not_to raise_error
    end
  end
end
