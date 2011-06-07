$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
require 'polyglot'
require 'treetop'

include OpenEHR::Parser

module OpenEHR
  module Parser
    class ADLParser < Base
      def initialize(filename)
        super(filename)
        data = File.read(filename)
        Treetop.load(File.dirname(__FILE__)+'/adl.tt')
        ap = ADLSyntaxParser.new
        @result = ap.parse(data)
        unless @result
          puts ap.failure_reason
          puts ap.failure_line
          puts ap.failure_column
        end
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
