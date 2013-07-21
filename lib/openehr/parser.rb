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

    require_relative 'parser/adl_parser'
  end
end
