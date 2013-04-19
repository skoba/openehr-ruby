require_relative '../parser'

module OpenEHR
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

