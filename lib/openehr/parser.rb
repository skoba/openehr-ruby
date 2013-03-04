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

    require 'parser/adl_parser'
#    require 'parser/adl_parser'
#    require 'parser/xml_perser'
#    require 'parser/exception'
#    require 'parser/scanner'
  end
end
