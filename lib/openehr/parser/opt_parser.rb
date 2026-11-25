require 'nokogiri'
require_relative 'xml_constraint_parsing'
require_relative 'xml_primitive_parsing'
require_relative 'xml_domain_type_parsing'

module OpenEHR
  module Parser
    class OPTParser < ::OpenEHR::Parser::Base
      include XMLConstraintParsing
      include XMLPrimitiveParsing
      include XMLDomainTypeParsing

      TEMPLATE_LANGUAGE_CODE_PATH =
        '/template/language/code_string'
      TEMPLATE_LANGUAGE_TERM_ID_PATH =
        '/template/language/terminology_id/value'
      TEMPLATE_ID_PATH = '/template/template_id/value'
      UID_PATH = '/template/uid/value'
      CONCEPT_PATH = '/template/concept'
      DESC_ORIGINAL_AUTHOR_PATH =
        '/template/description/original_author'
      DESC_LIFECYCLE_STATE_PATH =
        '/template/description/lifecycle_state'
      DESC_DETAILS_LANGUAGE_TERM_ID_PATH =
        '/template/description/details/language/terminology_id/value'
      DESC_DETAILS_LANGUAGE_CODE_PATH =
        '/template/description/details/language/code_string'
      DESC_DETAILS_PURPOSE_PATH =
        '/template/description/details/purpose'
      DESC_DETAILS_KEYWORDS_PATH =
        '/template/description/details/keywords'
      DESC_DETAILS_USE_PATH = '/template/description/details/use'
      DESC_DETAILS_MISUSE_PATH =
        '/template/description/details/misuse'
      DESC_DETAILS_COPYRIGHT_PATH =
        '/template/description/details/copyright'
      DESC_OTHER_DETAILS_PATH =
        '/template/description/other_details'
      DEFINITION_PATH = '/template/definition'
      OCCURRENCE_PATH = '/occurrences'

      # A parser for OPT XML already held in a String (#74), parsed with the
      # same SAFE_PARSE_OPTIONS as a path: OPTParser.from_xml(xml).parse.
      # Called on a subclass, it returns an instance of that subclass.
      # filename is nil for such a parser.
      def self.from_xml(xml)
        raise ArgumentError, "OPT XML must be a String, not #{xml.class}" unless xml.is_a?(String)

        new(nil).tap { |parser| parser.instance_variable_set(:@xml, xml) }
      end

      def parse
        @opt = read_document
        @opt.remove_namespaces!

        uid = build_uid
        defs = definition

        # Create operational template with archetype-compatible parameters
        OpenEHR::AM::Template::OperationalTemplate.new(
          uid: uid,
          concept: concept,
          original_language: language,
          description: description,
          template_id: template_id,
          archetype_id: template_id,  # Use template_id as archetype_id for compatibility
          definition: defs,
          ontology: (@component_terminologies || {})[defs.archetype_id.value] || create_template_ontology,
          component_terminologies: @component_terminologies || {},
          terminology_extracts: @component_terminologies || {},
          adl_version: "1.4"
        )
      end

      private

      def read_document
        return Nokogiri::XML::Document.parse(@xml, options: SAFE_PARSE_OPTIONS) if @xml

        File.open(@filename) do |file|
          Nokogiri::XML::Document.parse(file, options: SAFE_PARSE_OPTIONS)
        end
      end

      # template_id is mandatory for an operational template (enforced by
      # OperationalTemplate itself); a missing/blank <template_id> element
      # must therefore resolve to nil rather than an invalid TemplateID.
      def template_id
        return @template_id if @template_id
        value = text_on_path(@opt, TEMPLATE_ID_PATH)
        @template_id = value.nil? || value.empty? ? nil : OpenEHR::RM::Support::Identification::TemplateID.new(value: value)
      end

      # uid is optional on an operational template; a missing/blank <uid>
      # element must resolve to nil rather than an invalid UIDBasedID.
      def build_uid
        value = text_on_path(@opt, UID_PATH)
        value.nil? || value.empty? ? nil : OpenEHR::RM::Support::Identification::UIDBasedID.new(value: value)
      end

      def concept
        text_on_path(@opt, CONCEPT_PATH)
      end

      def language
        @language ||= OpenEHR::RM::DataTypes::Text::CodePhrase.new(code_string: text_on_path(@opt, TEMPLATE_LANGUAGE_CODE_PATH), terminology_id: OpenEHR::RM::Support::Identification::TerminologyID.new(value: text_on_path(@opt,TEMPLATE_LANGUAGE_TERM_ID_PATH)))
      end

      def description
        original_author = text_on_path(@opt, DESC_ORIGINAL_AUTHOR_PATH)
        lifecycle_state = text_on_path(@opt, DESC_LIFECYCLE_STATE_PATH)
        OpenEHR::RM::Common::Resource::ResourceDescription.new(original_author: original_author, lifecycle_state: lifecycle_state, details: [description_details], other_details: description_other_details)
      end

      def description_details
        terminology_id = OpenEHR::RM::Support::Identification::TerminologyID.new(value: text_on_path(@opt, DESC_DETAILS_LANGUAGE_TERM_ID_PATH))
        language = OpenEHR::RM::DataTypes::Text::CodePhrase.new(code_string: text_on_path(@opt, DESC_DETAILS_LANGUAGE_CODE_PATH), terminology_id: terminology_id)
        purpose = text_on_path(@opt, DESC_DETAILS_PURPOSE_PATH)
        keywords = @opt.xpath(DESC_DETAILS_KEYWORDS_PATH).inject([]) {|a, i| a << i.text}
        use = empty_then_nil text_on_path(@opt, DESC_DETAILS_USE_PATH)
        misuse = empty_then_nil text_on_path(@opt, DESC_DETAILS_MISUSE_PATH)
        copyright = empty_then_nil text_on_path(@opt, DESC_DETAILS_COPYRIGHT_PATH)
        OpenEHR::RM::Common::Resource::ResourceDescriptionItem.new(language: language, purpose: purpose, keywords: keywords, use: use, misuse: misuse, copyright: copyright)
      end

      def description_other_details
        @opt.xpath(DESC_OTHER_DETAILS_PATH).inject({}) do |hash, detail|
          hash[detail.attributes['id'].value] = detail.text
          hash
        end
      end

      def definition
        c_archetype_root @opt.xpath(DEFINITION_PATH)
      end

      def component_terminologies(archetype_id, nodes)
        @component_terminologies ||= Hash.new
        @component_terminologies[archetype_id.value] =
          archetype_terminology(nodes)
      end

      def create_template_ontology
        # Create a basic ontology for the template using the main concept
        concept_code = 'at0000'
        original_lang = language

        term_definitions = {
          original_lang.code_string => [
            OpenEHR::AM::Archetype::Terminology::ArchetypeTerm.new(
              code: concept_code,
              items: {
                'text' => concept || 'Template',
                'description' => 'Operational template'
              }
            )
          ]
        }

        OpenEHR::AM::Archetype::Terminology::ArchetypeTerminology.new(
          concept_code: concept_code,
          original_language: original_lang,
          term_definitions: term_definitions
        )
      end

      def archetype_terminology(nodes)
        td = term_definitions(nodes)
        concept_code = td[language.code_string][0]
        OpenEHR::AM::Archetype::Terminology::
          ArchetypeTerminology.new(
                concept_code: concept_code,
                original_language: language,
                term_definitions: td,
                term_bindings: opt_term_bindings(nodes))
      end

      # An OPT writes term_bindings as
      #   <term_bindings terminology="T"><items code="atNNNN"><value>
      #     <terminology_id><value>T</value></terminology_id>
      #     <code_string>[T::code]</code_string></value></items></term_bindings>
      # (a serialized CODE_PHRASE per item), not the flat
      # attribute-plus-text shape XMLArchetypeParser#ontology_bindings
      # reads. The result has the same in-memory shape on both paths:
      # { terminology => { code => [CodePhrase] } }. code_string is kept
      # exactly as written. nil (not {}) when the archetype has no
      # term_bindings, so "not populated" stays distinguishable.
      # The method name is deliberately not one openehr-rails'
      # OpenehrRails::Opt::Parser subclass already defines.
      def opt_term_bindings(nodes)
        bindings = nodes.xpath('term_bindings').each_with_object({}) do |binding, by_terminology|
          codes = (by_terminology[binding['terminology']] ||= {})
          binding.xpath('items').each do |item|
            (codes[item['code']] ||= []) << opt_binding_code_phrase(item)
          end
        end
        bindings.empty? ? nil : bindings
      end

      def opt_binding_code_phrase(item)
        OpenEHR::RM::DataTypes::Text::CodePhrase.new(
          code_string: text_on_path(item, './value/code_string'),
          terminology_id: OpenEHR::RM::Support::Identification::TerminologyID.new(
            value: text_on_path(item, './value/terminology_id/value')
          )
        )
      end

      def term_definitions(nodes)
        term_definitions = nodes.xpath 'term_definitions'
        term_items = term_definitions.map do |term|
          code = term.attributes['code'].value
          text = term.at('items[@id="text"]').text
          description = term.at('items[@id="description"]').text
          OpenEHR::AM::Archetype::Terminology::ArchetypeTerm.new(code: code, items: {'text' => text, 'description' => description})
        end
        { language.code_string => term_items }
      end

      # One C_ARCHETYPE_ROOT's own terms, for CArchetypeRoot#term_definitions:
      # { language => { code => ArchetypeTerm } }. Unlike
      # component_terminologies (keyed by archetype id, last root wins,
      # { language => [ArchetypeTerm] }), this is kept per root, so a
      # template's per-root renames survive (issue #58).
      def opt_root_term_definitions(nodes)
        term_definitions(nodes).transform_values do |terms|
          terms.to_h { |term| [term.code, term] }
        end
      end

      def empty_then_nil(val)
        if val.empty?
          return nil
        else
          return val
        end
      end

      def text_on_path(xml, path)
        xml.xpath(path).text
      end
    end
  end
end

class Node
  attr_accessor :id, :path
  attr_reader :parent

  def initialize(parent = nil)
    @parent = parent
    @path = '/' if parent.nil?
  end

  def root?
    parent.nil?
  end
end
