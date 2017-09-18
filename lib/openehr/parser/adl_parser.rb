require 'treetop'
#require 'polyglot'

require_relative '../parser'
#require_relative './adl_grammar'

module OpenEHR
  module Parser
    class ADLParser < ::OpenEHR::Parser::Base
      Treetop.load(File.join(File.dirname(__FILE__), 'adl_grammar.tt'))

      def initialize(filename)
        super
      end
      
      def parse
        archetype
      end

      private

      def adl_grammar_parser
        @adl_grammar_parser ||= ADLGrammarParser.new
      end

      def parsed_data
        filestream = File.open(@filename, 'rb:bom|utf-8')
        @parsed_data ||= adl_grammar_parser.parse(filestream.read)
        filestream.close
        unless @parsed_data
          puts adl_grammar_parser.failure_reason
          puts adl_grammar_parser.failure_line
          puts adl_grammar_parser.failure_column
          raise ParseError, 'Invalid ADL'
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

      def uid
        OpenEHR::RM::Support::Identification::HierObjectID.new(value: parsed_data.uid) if parsed_data.uid
      end

      def concept
        parsed_data.concept
      end

      def description
        parsed_data.description
      end

      def translations
        parsed_data.translations
      end

      def definition
        parsed_data.definition
      end

      def archetype
        OpenEHR::AM::Archetype::Archetype.new(:archetype_id => archetype_id,
                                  :adl_version => adl_version,
                                  :uid => uid,            
                                  :concept => concept,
                                  :original_language => original_language,
                                  :translations => translations,
                                  :description => description,
                                  :definition => definition,
                                  :ontology => ontology)
      end
    end
  end # of Parser
end # of OpenEHR
