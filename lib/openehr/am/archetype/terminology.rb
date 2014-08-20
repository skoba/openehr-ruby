require_relative './ontology'
# Archetype Ontology module was renamed to Terminology at spec 1.1.0
module OpenEHR
  module AM
    module Archetype
      module Terminology
        class ArchetypeTerminology < OpenEHR::AM::Archetype::Ontology::ArchetypeOntology
        end

        class ArchetypeTerm < OpenEHR::AM::Archetype::Ontology::ArchetypeTerm
        end
      end
    end
  end
end
