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
        @result = ADL.parse(data, :memoize => true)
      rescue Citrus::ParseError => e
        p e.line
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

    class CADLParser
      def initialize(filename)
        data = File.read(filename)
        Citrus.load(File.dirname(__FILE__)+'/cadl.citrus')
        @result = CADL.parse(data, :memoize => true)
      end
    end
  end # of Parser
end # of OpenEHR
