require 'nokogiri'

module OpenEHR
  module Parser
    class OPTParser < ::OpenEHR::Parser::Base
      TEMPLATE_LANGUAGE_CODE_PATH = '/template/language/code_string'
      TEMPLATE_LANGUAGE_TERM_ID_PATH = '/template/language/terminology_id/value'
      DESC_ORIGINAL_AUTHOR_PATH = '/template/description/original_author'
      DESC_LIFECYCLE_STATE_PATH = '/template/description/lifecycle_state'
      DESC_DETAILS_LANGUAGE_TERM_ID_PATH = '/template/description/details/language/terminology_id/value'
      DESC_DETAILS_LANGUAGE_CODE_PATH = '/template/description/details/language/code_string'
      DESC_DETAILS_PURPOSE_PATH = '/template/description/details/purpose'
      DESC_DETAILS_KEYWORDS_PATH = '/template/description/details/keywords'
      DESC_DETAILS_USE_PATH = '/template/description/details/use'
      DESC_DETAILS_MISUSE_PATH = '/template/description/details/misuse'
      DESC_DETAILS_COPYRIGHT_PATH = '/template/description/details/copyright'
      def initialize(filename)
        super(filename)
      end

      def parse
        opt = Nokogiri::XML::Document.parse(File.open(@filename))
        terminology_id = OpenEHR::RM::Support::Identification::TerminologyID.new(value: text_on_path(opt,TEMPLATE_LANGUAGE_TERM_ID_PATH))
        language = OpenEHR::RM::DataTypes::Text::CodePhrase.new(code_string: text_on_path(opt, TEMPLATE_LANGUAGE_CODE_PATH), terminology_id: terminology_id)
        original_author = text_on_path(opt, DESC_ORIGINAL_AUTHOR_PATH)
        lifecycle_state = text_on_path(opt, DESC_LIFECYCLE_STATE_PATH)
        details_terminology_id = OpenEHR::RM::Support::Identification::TerminologyID.new(value: text_on_path(opt, DESC_DETAILS_LANGUAGE_TERM_ID_PATH))
        details_language = OpenEHR::RM::DataTypes::Text::CodePhrase.new(code_string: text_on_path(opt, DESC_DETAILS_LANGUAGE_CODE_PATH), terminology_id: details_terminology_id)
        details_purpose = text_on_path(opt, DESC_DETAILS_PURPOSE_PATH)
        details_keywords = opt.xpath(DESC_DETAILS_KEYWORDS_PATH).inject([]) {|a, i| a << i.text}
        details_use = empty_then_nil text_on_path(opt, DESC_DETAILS_USE_PATH)
        details_misuse = empty_then_nil text_on_path(opt, DESC_DETAILS_MISUSE_PATH)
        details_copyright = empty_then_nil text_on_path(opt, DESC_DETAILS_COPYRIGHT_PATH)
        details = OpenEHR::RM::Common::Resource::ResourceDescriptionItem.new(language: details_language, purpose: details_purpose, keywords: details_keywords, use: details_use, misuse: details_misuse, copyright: details_copyright)
        description = OpenEHR::RM::Common::Resource::ResourceDescription.new(original_author: original_author, lifecycle_state: lifecycle_state, details: [details])
        OpenEHR::AM::Template::OperationalTemplate.new(language: language, description: description)
      end

      private
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
