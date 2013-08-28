require 'treetop'
require 'polyglot'

require_relative '../parser'

module OpenEHR
  module Parser

    class ADLParser < ::OpenEHR::Parser::Base
      Treetop.load(File.dirname(__FILE__)+'/adl_grammar.tt')

      def initialize(filename)
        super(filename)
      end
      
      def parse
        result = parsed_data
        archetype = OpenEHR::AM::Archetype::Archetype.new(:archetype_id => archetype_id,
                                  :adl_version => adl_version,
                                  :concept => concept,
                                  :original_language => original_language,
                                  :translations => translations,
                                  :description => result.description,
                                  :definition => result.definition,
                                  :ontology => ontology)
        return archetype
      end

      private

      def adl_grammar_parser
        @adl_grammar_parser ||= ADLGrammarParser.new
      end

      def parsed_data
        filestream = File.open(filename, 'r:bom|utf-8')
        @parsed_data ||= adl_grammar_parser.parse(filestream.read)
        filestream.close
        unless @parsed_data
          puts adl_grammar_parser.failure_reason
          puts adl_grammar_parser.failure_line
          puts adl_grammar_parser.failure_column
        end
        @parsed_data
      end

      def archetype_id
        OpenEHR::RM::Support::Identification::ArchetypeID.new(:value => parsed_data.archetype_id)
      end

      def ontology
        parsed_data.ontology
      end

      def original_language
        original_language = nil
        if parsed_data.original_language
          original_language = parsed_data.original_language
        else
          terminology_id = OpenEHR::RM::Support::Identification::TerminologyID.new(:value => 'ISO639-1')
          original_language = OpenEHR::RM::DataTypes::Text::CodePhrase.new(:terminology_id => terminology_id, :code_string => ontology.primary_language)
        end
        original_language
      end

      def adl_version
        parsed_data.adl_version
      end

      def concept
        parsed_data.concept
      end

      def translations
        parsed_data.translations
      end
    end
  end # of Parser
end # of OpenEHR
