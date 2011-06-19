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
        Treetop.load(File.dirname(__FILE__)+'/adl_grammar.tt')
        ap = ADLGrammarParser.new
        @result = ap.parse(data)
        if @result.nil?
          puts ap.failure_reason
          puts ap.failure_line
          puts ap.failure_column
        end
      end

      def parse
        archetype = ArchetypeMock.new(:archetype_id => @result.archetype_id,
                                      :adl_version => @result.adl_version,
                                      :concept => @result.concept,
                                      :original_language => @result.original_language,
                                      :translation => @result.translations,
                                      :description => @result.description,
                                      :definition => @result.definition)
        return archetype
      end

# temporary class for parser building

      class ArchetypeMock
        def initialize(args = { })
          @params = args
        end

        def method_missing(name)
          @params[name]
        end
      end
    end
  end # of Parser
end # of OpenEHR
