module OpenEHR
  module Parser
    module ADLGrammar
      class Base < Treetop::Runtime::SyntaxNode

      end

      class Archetype < Base
        def archetype_id
          ArchIdentification.archetype_id
        end

        def adl_version
          ArchMetaDataItems.adl_version
        end
      end

     class ArchIdentification < Base
        def archetype_id
          @elements[1].text_value
        end
      end

      class ArchHead < Base
        def adl_version
          p @elements.each{ |e| e.text_value }
          ArchMetaData.adl_version
        end
      end

      class ArchMetaData < Base
        def adl_version
          ArchMetaDataItems.content
        end

        def is_controled?
          ArchMetaDataItems.content
        end
      end
      
      module ArchMetaDataItems #< Base
        def self.adl_version
          p name #@elements.each {|e| e.text_value}
        end
      end

      class ArchMetaDataItem < Base
        def self.content
          p @elements
        end
      end
    end
  end
end
