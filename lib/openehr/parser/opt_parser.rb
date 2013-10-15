module OpenEHR
  module Parser
    class OPTParser < ::OpenEHR::Parser::Base
      def initialize(filename)
        super(filename)
      end

      def parse
        xml = Nokogiri::XML::Document.parse(File(__FILE__ + '/eReferral.opt'))
        terminology = OpenEHR::RM::Support::Identification::TerminologyID.new(value:)
        OpenEHR::AM::Template::OperationalTemplate.new(language: language)
      end
    end
  end
end
