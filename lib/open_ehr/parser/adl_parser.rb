$:.unshift(File.dirname(__FILE__)) unless
  $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
require 'citrus'
include OpenEHR::Parser

module OpenEHR
  module Parser
    class ADLParser
      def initialize(filename)
        super(filename)
        Citrus.load(File.dirname(__FILE__) + '/adl')
        ADL.parse(@data)
      end
    end
  end # of Parser
end # of OpenEHR
