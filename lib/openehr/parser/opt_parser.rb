require 'nokogiri'

module OpenEHR
  module Parser
    class OPTParser < ::OpenEHR::Parser::Base
      TEMPLATE_LANGUAGE_CODE_PATH = '/template/language/code_string'
      TEMPLATE_LANGUAGE_TERM_ID_PATH = '/template/language/terminology_id/value'
      TEMPLATE_ID_PATH = '/template/template_id/value'
      CONCEPT_PATH = '/template/concept'
      DESC_ORIGINAL_AUTHOR_PATH = '/template/description/original_author'
      DESC_LIFECYCLE_STATE_PATH = '/template/description/lifecycle_state'
      DESC_DETAILS_LANGUAGE_TERM_ID_PATH = '/template/description/details/language/terminology_id/value'
      DESC_DETAILS_LANGUAGE_CODE_PATH = '/template/description/details/language/code_string'
      DESC_DETAILS_PURPOSE_PATH = '/template/description/details/purpose'
      DESC_DETAILS_KEYWORDS_PATH = '/template/description/details/keywords'
      DESC_DETAILS_USE_PATH = '/template/description/details/use'
      DESC_DETAILS_MISUSE_PATH = '/template/description/details/misuse'
      DESC_DETAILS_COPYRIGHT_PATH = '/template/description/details/copyright'
      DEFINITION_PATH = '/template/definition'

      def initialize(filename)
        super(filename)
      end

      def parse
        @opt = Nokogiri::XML::Document.parse(File.open(@filename))
        terminology_id = OpenEHR::RM::Support::Identification::TerminologyID.new(value: text_on_path(@opt,TEMPLATE_LANGUAGE_TERM_ID_PATH))
        language = OpenEHR::RM::DataTypes::Text::CodePhrase.new(code_string: text_on_path(@opt, TEMPLATE_LANGUAGE_CODE_PATH), terminology_id: terminology_id)
        root_rm_type = text_on_path(@opt, DEFINITION_PATH + '/rm_type_name')
        root_node_id = text_on_path(@opt, DEFINITION_PATH + '/node_id')
        root_occurrences_lower = text_on_path(@opt, DEFINITION_PATH + '/occurrences/lower')
        root_occurrences_upper = text_on_path(@opt, DEFINITION_PATH + '/occurrences/upper')
        root_occurrences_lower_included = text_on_path(@opt, DEFINITION_PATH + '/occurrences/lower_included')
        root_occurrences_upper_included = text_on_path(@opt, DEFINITION_PATH + '/occurrences/upper_included')
        root_occurrences_lower_unbounded = text_on_path(@opt, DEFINITION_PATH + '/occurrences/lower_unbounded')
        root_occurrences_upper_unbounded = text_on_path(@opt, DEFINITION_PATH + '/occurrences/upper_unbounded')
        root_occurrences = OpenEHR::AssumedLibraryTypes::Interval.new(lower: root_occurrences_lower, upper: root_occurrences_upper, lower_included: root_occurrences_lower_included, upper_included: root_occurrences_upper_included, lower_unbounded: root_occurrences_lower_unbounded, upper_unbounded: root_occurrences_upper_unbounded)
        definition = OpenEHR::AM::Archetype::ConstraintModel::CArchetypeRoot.new(rm_type_name: root_rm_type, node_id: root_node_id, occurrences: root_occurrences)
        OpenEHR::AM::Template::OperationalTemplate.new(concept: concept, language: language, description: description, template_id: template_id, definition: definition)
      end

      private

      def template_id
        OpenEHR::RM::Support::Identification::TemplateID.new(value: text_on_path(@opt, TEMPLATE_ID_PATH))
      end

      def concept
        text_on_path(@opt, CONCEPT_PATH)
      end

      def description
        original_author = text_on_path(@opt, DESC_ORIGINAL_AUTHOR_PATH)
        lifecycle_state = text_on_path(@opt, DESC_LIFECYCLE_STATE_PATH)
        OpenEHR::RM::Common::Resource::ResourceDescription.new(original_author: original_author, lifecycle_state: lifecycle_state, details: [description_details])
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
