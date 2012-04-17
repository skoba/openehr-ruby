module OpenEHR
  module Parser
    module Exception
      class Base < RuntimeError
      end

      module Scanner
        class Base < RuntimeError
        end
      end

      module Parser
        class Base < RuntimeError
        end

        class Error < Base
        end
      end


      #
      #
      # c.f. beale07:_archet_defin_languag,p.100
      module Validation
        class Base < RuntimeError
        end

        class VARID < Base
          MESSAGE = "The archetype must have an identifier value for the archetype_id section. The identifier must conform to the published openEHR specification for archetype identifiers."
        end

        class VARCN < Base
          MESSAGE = "The archetype must have an archetype term value in concept section. The term must exist in the archetype ontology."
        end

        class VARDF < Base
          MESSAGE = "The archetype must have a definition section, expressed as a cADL syntax."
        end

        class VARON < Base
          MESSAGE = "The archetype must have a ontology section, expressed as a dADL syntax."
        end

        class VARDT < Base
          MESSAGE = "The topmost typename mentioned in the archetype definition section must match the type mentioned in the type-name slot of the first segment of the archetype id."
        end

        class VATDF < Base
          MESSAGE = "Each archetype term used as a node identifier the archetype definition must be defined in the term_definitions part of the ontology."
        end

        class VACDF < Base
          MESSAGE = "Each constraint code used in the archetype definition must be defined in the constraint_definition part of the ontology."
        end

        class VDFAI < Base
          MESSAGE = "Any archetype identifier mentioned in an archetype slot in the definition section must conform to the published openEHR specification for archetype identifiers."
        end

        class VDFPT < Base
          MESSAGE = "Any path mentioned in the definition section must be valid syntactically, and a valid path with respect to the hierarchical structure of the definition section."
        end
      end

    end
  end
end

