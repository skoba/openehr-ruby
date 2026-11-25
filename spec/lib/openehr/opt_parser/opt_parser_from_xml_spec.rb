# frozen_string_literal: true

require File.dirname(__FILE__) + '/../../../spec_helper'

# Issue #74, resolution shape (b) enhancement: OPTParser.from_xml(xml).parse
# parses OPT XML held in a String, with the same SAFE_PARSE_OPTIONS as a
# path, so that a caller no longer has to override #parse. Plan:
# docs/design/74-opt-in-memory-entry.md. Written red-first against master
# c778509.
#
# Fixtures: minimum_template.opt and eReferral.opt (existing real fixtures,
# read as Strings). The XXE case is built here, from minimum_template.opt
# and the security fixture security_fixtures/xxe_sentinel.txt; it is not a
# clinical artifact.
describe 'OpenEHR::Parser::OPTParser.from_xml (#74)' do
  let(:parser_class) { OpenEHR::Parser::OPTParser }
  let(:safe_options) { OpenEHR::Parser::Base::SAFE_PARSE_OPTIONS }

  def fixture(file)
    File.join(File.dirname(__FILE__), file)
  end

  def summary(template)
    {
      template_id: template.template_id.value,
      uid: template.uid&.value,
      concept: template.concept,
      root_archetype_id: template.definition.archetype_id.value,
      paths: template.physical_paths.sort,
      component_terminologies: template.component_terminologies.keys.sort
    }
  end

  %w[minimum_template.opt eReferral.opt].each do |file|
    it "parses #{file} from a String to the same template as from its path" do
      from_string = parser_class.from_xml(File.read(fixture(file))).parse
      from_path = parser_class.new(fixture(file)).parse
      expect(summary(from_string)).to eq(summary(from_path))
    end
  end

  it 'parses the String with SAFE_PARSE_OPTIONS' do
    allow(Nokogiri::XML::Document).to receive(:parse).and_call_original
    parser_class.from_xml(File.read(fixture('minimum_template.opt'))).parse
    expect(Nokogiri::XML::Document).to have_received(:parse).with(kind_of(String), options: safe_options)
  end

  it 'does not expand an external entity in the String' do
    sentinel = File.expand_path('../parser/security_fixtures/xxe_sentinel.txt', __dir__)
    xml = File.read(fixture('minimum_template.opt'))
              .sub('<?xml version="1.0" encoding="utf-8"?>',
                   %(<?xml version="1.0" encoding="utf-8"?>\n<!DOCTYPE template [ <!ENTITY xxe SYSTEM "file://#{sentinel}"> ]>))
              .sub('<concept>minimum template</concept>', '<concept>&xxe;</concept>')
    template = parser_class.from_xml(xml).parse
    expect(template.concept.to_s).not_to include('XXE-SENTINEL-CONTENT')
  end

  it 'tolerates a leading UTF-8 BOM' do
    xml = "﻿#{File.read(fixture('minimum_template.opt'))}"
    expect(parser_class.from_xml(xml).parse.template_id.value).to eq('minimum template')
  end

  it 'returns an instance of the subclass it is called on' do
    subclass = Class.new(parser_class)
    parser = subclass.from_xml(File.read(fixture('minimum_template.opt')))
    expect(parser).to be_a(subclass)
    expect(parser.filename).to be_nil
  end

  it 'raises ArgumentError for an argument that is not a String' do
    expect { parser_class.from_xml(nil) }.to raise_error(ArgumentError)
    expect { parser_class.from_xml(File.open(fixture('minimum_template.opt'))) }.to raise_error(ArgumentError)
  end

  it 'keeps OPTParser.new(path).parse as it was (regression pin)' do
    # regression pin: the path entry point is unchanged by #74.
    expect(parser_class.new(fixture('minimum_template.opt')).parse.template_id.value).to eq('minimum template')
  end
end
