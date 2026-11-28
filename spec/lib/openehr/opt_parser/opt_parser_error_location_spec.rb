# frozen_string_literal: true

require File.dirname(__FILE__) + '/../../../spec_helper'
require 'tempfile'

# #159 (R-20261128-12), resolution shape (b) enhancement: OPTParser reads
# with RECOVER (#36 kept it). When libxml2 recorded errors in the document
# and the parse then fails, OPTParser#parse raises ParseError saying where
# libxml2 found the first error, with the original exception as cause.
# Before #159 it raised that original exception (here ArgumentError
# 'invalid archetype id form'), which says nothing about the XML.
describe 'OpenEHR::Parser::OPTParser error location (#159)' do
  let(:broken) { '<?xml version="1.0"?><invalid><unclosed>' }

  def parse_xml(xml) = OpenEHR::Parser::OPTParser.from_xml(xml).parse

  def parse_file(xml)
    file = Tempfile.new(['broken', '.opt'])
    file.write(xml)
    file.close
    [file.path, -> { OpenEHR::Parser::OPTParser.new(file.path).parse }]
  end

  it 'raises ParseError with the libxml2 line, column and text (from_xml)' do
    expect { parse_xml(broken) }.to raise_error(OpenEHR::Parser::ParseError) { |error|
      expect(error.message).to include('line 1, column 41', 'Premature end of data in tag unclosed')
      expect(error.message).to include('ArgumentError: invalid archetype id form')
    }
  end

  it 'keeps the original exception as cause' do
    expect { parse_xml(broken) }.to raise_error(OpenEHR::Parser::ParseError) { |error|
      expect(error.cause).to be_a(ArgumentError)
    }
  end

  it 'names the file when parsing a path' do
    path, parse = parse_file(broken)
    expect(&parse).to raise_error(OpenEHR::Parser::ParseError, /#{Regexp.escape(path)}.*line 1, column 41/)
  end

  # regression pin: a document whose only libxml2 error is a double
  # hyphen in a comment already parsed before #159, and still does.
  it 'still parses a document whose libxml2 errors do not break it (regression pin)' do
    xml = File.read(File.expand_path('minimum_template.opt', __dir__))
                .sub('<!--Operational template', '<!-- a -- b --><!--Operational template')
    expect(Nokogiri::XML::Document.parse(xml, nil, nil, OpenEHR::Parser::Base::SAFE_PARSE_OPTIONS).errors).not_to be_empty
    expect(parse_xml(xml).template_id.value).to eq OpenEHR::Parser::OPTParser.new(File.expand_path('minimum_template.opt', __dir__)).parse.template_id.value
  end

  # regression pin: with no libxml2 error, the exception type is unchanged.
  it 'keeps ArgumentError for an empty document, which has no libxml2 error (regression pin)' do
    expect { parse_xml('') }.to raise_error(ArgumentError, 'invalid archetype id form')
  end

  # regression pin: a missing file is not an XML error.
  it 'keeps Errno::ENOENT for a missing file (regression pin)' do
    expect { OpenEHR::Parser::OPTParser.new('/non/existent/file.opt').parse }.to raise_error(Errno::ENOENT)
  end
end
