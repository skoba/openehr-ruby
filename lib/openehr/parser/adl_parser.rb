require 'treetop'
require 'polyglot'

require_relative '../parser'

module OpenEHR
  module Parser

    class ADLParser < ::OpenEHR::Parser::Base
      Treetop.load(File.dirname(__FILE__)+'/adl_grammar.tt')

      def initialize(filename)
        super(filename)
        file = File.open(filename, 'r:bom|utf-8')
        data = file.read
        ap = ADLGrammarParser.new
        @result = ap.parse(data)
        file.close
        unless @result
          puts ap.failure_reason
          puts ap.failure_line
          puts ap.failure_column
        end
      end

      def parse
        archetype_id = OpenEHR::RM::Support::Identification::ArchetypeID.new(:value => @result.archetype_id)
        ontology = @result.ontology
        original_language = nil
        if @result.original_language
          original_language = @result.original_language
        else
          terminology_id = OpenEHR::RM::Support::Identification::TerminologyID.new(:value => 'ISO639-1')
          original_language = OpenEHR::RM::DataTypes::Text::CodePhrase.new(:terminology_id => terminology_id,
                                      :code_string =>ontology.primary_language)
        end
        archetype = OpenEHR::AM::Archetype::Archetype.new(:archetype_id => archetype_id,
                                  :adl_version => @result.adl_version,
                                  :concept => @result.concept,
                                  :original_language => original_language,
                                  :translations => @result.translations,
                                  :description => @result.description,
                                  :definition => @result.definition,
                                  :ontology => @result.ontology)
        return archetype
      end
    end
  end # of Parser
end # of OpenEHR
