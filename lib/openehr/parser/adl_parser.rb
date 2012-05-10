$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
require 'treetop'
require 'polyglot'
include OpenEHR::Parser
include OpenEHR::AM::Archetype
include OpenEHR::RM::Support::Identification
include OpenEHR::RM::DataTypes::Text

module OpenEHR
  module Parser
    class ADLParser < Base
      def initialize(filename)
        super(filename)
        file = File.open(filename, 'r:bom|utf-8')
        data = file.read
        Treetop.load(File.dirname(__FILE__)+'/adl_grammar.tt')
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
        archetype_id = ArchetypeID.new(:value => @result.archetype_id)
        definition = @result.definition
        ontology = @result.ontology
        original_language = nil
        if @result.original_language
          original_language = @result.original_language
        else
          terminology_id = TerminologyID.new(:value => 'ISO639-1')
          original_language = CodePhrase.new(:terminology_id => terminology_id,
                                      :code_string =>ontology.primary_language)
        end
        archetype = Archetype.new(:archetype_id => archetype_id,
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
