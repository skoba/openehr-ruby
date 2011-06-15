module OpenEHR
  module Parser
    module ADLGrammar
      class Base < Treetop::Runtime::SyntaxNode

      end

      class ArchLanguage < Base
        def original_language
          lang.value[:original_language]
        end

        def translations
          lang.value[:translations]
        end
      end
    end
  end
end
