module OpenEHR
  module AQL
    module Model
      # identifiedPath : IDENTIFIER pathPredicate? (SYM_SLASH objectPath)? ;
      # A variable reference, optionally followed by an object path rooted
      # at that variable (e.g. "o/data[at0001]/.../value"). `path` stays
      # nil until M4 adds objectPath parsing.
      class IdentifiedPath
        attr_reader :variable, :path

        def initialize(variable:, path: nil)
          @variable = variable
          @path = path
          freeze
        end
      end
    end
  end
end
