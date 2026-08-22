require File.dirname(__FILE__) + '/../../../spec_helper'
require File.dirname(__FILE__) + '/../adl_parser/parser_spec_helper'
require 'tempfile'

describe 'safe XML parsing' do
  let(:safe_options) { OpenEHR::Parser::Base::SAFE_PARSE_OPTIONS }

  describe 'parser integration' do
    it 'passes SAFE_PARSE_OPTIONS when OPTParser parses an operational template' do
      fixture = File.expand_path('../opt_parser/minimum_template.opt', __dir__)
      allow(Nokogiri::XML::Document).to receive(:parse).and_call_original

      OpenEHR::Parser::OPTParser.new(fixture).parse

      expect(Nokogiri::XML::Document).to have_received(:parse)
        .with(anything, options: safe_options)
    end

    it 'passes SAFE_PARSE_OPTIONS when XMLArchetypeParser parses an archetype' do
      archetype = adl14_archetype('openEHR-EHR-CLUSTER.anatomical_location.v1.adl')
      xml = OpenEHR::Serializer::XMLSerializer.new(archetype).merge
      tempfile = Tempfile.new(['xxe_safety_xml_archetype', '.xml'])
      tempfile.write(xml)
      tempfile.close
      allow(Nokogiri::XML::Document).to receive(:parse).and_call_original

      OpenEHR::Parser::XMLArchetypeParser.new(tempfile.path).parse

      expect(Nokogiri::XML::Document).to have_received(:parse)
        .with(anything, options: safe_options)
    ensure
      tempfile&.unlink
    end
  end

  describe 'XXE attack regression fixtures' do
    let(:fixture_directory) { File.expand_path('security_fixtures', __dir__) }
    let(:marker) { 'XXE-SENTINEL-CONTENT' }

    def security_fixture(directory, filename)
      File.read(File.join(directory, filename)).gsub('__SECURITY_FIXTURE_DIR__', directory)
    end

    # These are direct Nokogiri contract checks using the exact invocation shape
    # used by both parsers. This keeps the test focused on SAFE_PARSE_OPTIONS
    # without wrapping a deliberately hostile document in a fake openEHR artifact.
    # They are regression pins, not red-to-green behavior changes: Nokogiri's
    # currently resolved implicit defaults already reject both attacks.
    %w[xxe_entity_attack.xml xxe_external_dtd_attack.xml].each do |fixture_name|
      it "does not resolve #{fixture_name} with SAFE_PARSE_OPTIONS" do
        xml = security_fixture(fixture_directory, fixture_name)
        document = Nokogiri::XML::Document.parse(xml, options: safe_options)

        expect(document.root.text).not_to include(marker)
      end
    end

    # This is a dependency-contract test for Nokogiri rather than gem behavior.
    # It proves the same local-only payloads resolve when the unsafe NOENT and
    # DTDLOAD flags are deliberately enabled, demonstrating why both stay off.
    %w[xxe_entity_attack.xml xxe_external_dtd_attack.xml].each do |fixture_name|
      it "resolves #{fixture_name} with deliberately unsafe options" do
        unsafe_options = Nokogiri::XML::ParseOptions.new(
          safe_options.to_i |
          Nokogiri::XML::ParseOptions::NOENT |
          Nokogiri::XML::ParseOptions::DTDLOAD
        )
        xml = security_fixture(fixture_directory, fixture_name)
        document = Nokogiri::XML::Document.parse(xml, options: unsafe_options)

        expect(document.root.text).to include(marker)
      end
    end
  end
end
