$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
require 'citrus'
include OpenEHR::Parser

module OpenEHR
  module Parser
    class ADLParser
      def initialize(filename)
        super(filename)
        data = File.read(filename)
        Citrus.load(File.dirname(__FILE__)+'/adl.citrus')
        @result = ADL.parse(data)
      rescue Citrus::ParseError => e
        raise ArgumentError, "Invalid data on line %d, offset %d!" %[e.line_number, e.line_offset]
      end


      def parse
        archetype = ArchetypeMock.new(:archetype_id => @result.archetype_id)
        return archetype
      end

# temporary class for parser building

      class ArchetypeMock
        attr_reader :archetype_id
        def initialize(args = { })
          @archetype_id = args[:archetype_id]
        end
      end
    end
  end # of Parser
end # of OpenEHR
