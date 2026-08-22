require 'nokogiri'

module OpenEHR
  module Parser
    class Base
      # Explicit, safe Nokogiri ParseOptions for untrusted OPT/archetype XML.
      # Deliberately lists RECOVER|NONET|BIG_LINES by name rather than
      # referencing Nokogiri::XML::ParseOptions::DEFAULT_XML - the whole
      # point is to not silently follow that constant if a future Nokogiri
      # release (or a downstream app pinning an older one) changes it.
      #
      # - RECOVER: parse malformed-but-well-intentioned XML leniently
      #   (matches today's implicit default; see
      #   docs/design/xxe-safe-parse-options-plan.md for real-fixture
      #   evidence that at least one downstream consumer OPT currently
      #   depends on this).
      # - NONET: forbid network access during parsing. Nokogiri's own docs:
      #   "UNSAFE to unset this option" for untrusted input.
      # - BIG_LINES: line numbers as `long int`, unrelated to safety.
      # - NOENT (entity substitution) and DTDLOAD (external DTD subset
      #   loading) are deliberately NOT set - both default off in Nokogiri
      #   and both documented "UNSAFE to set...for untrusted documents".
      #   This is what actually gates XXE (see the plan's attack-proof
      #   section: enabling either makes local-file and external-DTD
      #   entity resolution succeed).
      SAFE_PARSE_OPTIONS = Nokogiri::XML::ParseOptions.new(
        Nokogiri::XML::ParseOptions::RECOVER |
        Nokogiri::XML::ParseOptions::NONET |
        Nokogiri::XML::ParseOptions::BIG_LINES
      )

      attr_reader :filename

      def initialize(filename)
        @filename = filename
      end

      def parse
        raise NotImplementedError
      end
    end

    class ParseError < StandardError

    end

    require_relative 'parser/exception'
    require_relative 'parser/adl_parser'
    require_relative 'parser/opt_parser'
    require_relative 'parser/xml_archetype_parser'
    require_relative 'parser/archetype_validator'
  end
end
