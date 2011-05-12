$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
module OpenEHR
  module Parser
    autoload :ADLParser, 'parser/adl_parser'
    autoload :XMLParser, 'parser/xml_perser'
    autoload :Exeption, 'parser/exception'
    autoload :Scanner, 'parser/scanner'
  end
end
