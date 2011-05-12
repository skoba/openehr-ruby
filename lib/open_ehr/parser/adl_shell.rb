$:.unshift File.join(File.dirname(__FILE__))
require 'validator.rb'
require 'stringio'

module OpenEhr
  module Application
    class Shell
      def run
        raise 'not implemented'
      end
    end

    class ADLValidator < Shell
      def initialize(validator)
        @validator = validator
      end

      def run(input, name = nil)
        input_stream = case input
                       when String
                         StringIO.new(input)
                       when File
                         input
                       when StringIO
                         input
                       else
                         raise
                       end
        @validator.validate(input_stream.read, name)
        input_stream.close
      end
    end
  end
end
