module OpenEHR
  module Parser
    class Base
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
