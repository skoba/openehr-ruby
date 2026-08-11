module OpenEHR
  module Serializer
    NL = "\r\n"
    INDENT = '    '

    class BaseSerializer
      def initialize(archetype)
        @archetype = archetype
      end

      def serialize
        return self.merge
      end

      private
      def merge
      end
    end
  end
end
