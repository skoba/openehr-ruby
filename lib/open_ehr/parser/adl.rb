module ADLSyntax
  class Archetype < Treetop::Runtime::SyntaxNode
    def archetype_id
      arch_identification.archetype_id
    end

    def adl_version
      arch_identification.adl_version
    end
  end

  class ArchIdentification < Treetop::Runtime::SyntaxNode
    def archetype_id
      V_ARCHETYPE_ID.text_value
    end

    def adl_version
      arch_head.adl_version
    end
  end
end
