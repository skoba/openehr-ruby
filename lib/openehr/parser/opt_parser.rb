require 'nokogiri'

module OpenEHR
  module Parser
    class OPTParser < ::OpenEHR::Parser::Base
      def initialize(filename)
        super(filename)
      end

      def parse
        opt = Nokogiri::XML::Document.parse(File.open(@filename))
        opt.remove_namespaces!
        terminology_id = OpenEHR::RM::Support::Identification::TerminologyID.new(value: opt.xpath('/template/language/terminology_id/value').text)
        language = OpenEHR::RM::DataTypes::Text::CodePhrase.new(code_string: opt.xpath('/template/language/code_string').text, terminology_id: terminology_id)
        OpenEHR::AM::Template::OperationalTemplate.new(language: language)
      end
    end
  end
end
