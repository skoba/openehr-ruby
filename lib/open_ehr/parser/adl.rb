module ADLGrammar
  class ArchetypeParams
    
  end

  module Archetype  #< Treetop::Runtime::SyntaxNode
    def archetype_id
      ArchIdentification.archtype_id
    end

    def adl_version
      ArchHead.adl_version
    end
  end

  module ArchIdentification #< Treetop::Runtime::SyntaxNode
    def archetype_id
      @elements[1].text_value
    end

    def adl_version
      ArchHead.adl_version
    end
  end

  module ArchHead
    def adl_version
      p @elements
      ArchMetaData.adl_version
    end
  end

  module ArchMetaData
    def self.adl_version
      ArchMetaDataItems.content
    end

    def self.is_controled?
      ArchMetaDataItems.content
    end
  end
  
  module ArchMetaDataItems #< Treetop::Runtime::SyntaxNode
    def self.content
      ArchMetaDataItem.content
    end
  end

  module ArchMetaDataItem
    def self.content
      p @elements
    end
  end
end
