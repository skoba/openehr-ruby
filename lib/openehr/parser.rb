$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
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

    autoload :ADLParser, 'parser/adl_parser'
#    autoload :CADLParser, 'parser/adl_parser'
#    autoload :XMLParser, 'parser/xml_perser'
#    autoload :Exception, 'parser/exception'
#    autoload :Scanner, 'parser/scanner'
  end
end
