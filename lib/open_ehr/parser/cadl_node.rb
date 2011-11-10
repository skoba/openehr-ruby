require 'treetop'

module OpenEHR
  module Parser
    class ArchetypeNode
      def initialize(parent)
        @parent = parent
      end

      def parent
        
      end

      def path
        @path ||= '/'
      end
    end
  end
end
