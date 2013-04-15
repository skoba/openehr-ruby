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

    require 'openehr/parser/adl_parser'
    # require 'parser/xml_perser'
  end
end
