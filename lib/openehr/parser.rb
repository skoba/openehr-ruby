require_relative 'parser/adl_parser'
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
  end
end
