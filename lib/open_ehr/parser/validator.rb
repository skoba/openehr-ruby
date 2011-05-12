$:.unshift File.join(File.dirname(__FILE__))
require 'parser.rb'


module OpenEhr
  module ADL

    class Validator
      def initialize(parser)
        @parser = parser
      end

      def validate(input_string, name = nil)
        @parser.parse(input_string, name)
      end
    end

  end
end

