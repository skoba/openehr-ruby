module OpenEHR
  module Parser
    class Base
      attr_reader :filename

      def initialize(filename)
        @filename = filename
      end

      def parse
        raise NotImplementedError
      end
    end
  end
end
