module OpenEHR
  module AQL
    module Model
      # identifiedPath : IDENTIFIER pathPredicate? (SYM_SLASH objectPath)? ;
      # A variable reference, optionally constrained by a predicate on the
      # variable itself (e.g. "c[at001 or at002]"), optionally followed by
      # an object path rooted at that variable (e.g. "o/data[at0001]/.../value").
      class IdentifiedPath
        attr_reader :variable, :predicate, :path

        def initialize(variable:, predicate: nil, path: nil)
          @variable = variable
          @predicate = predicate
          @path = path
          freeze
        end
      end
    end
  end
end
