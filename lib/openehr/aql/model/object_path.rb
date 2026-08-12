module OpenEHR
  module AQL
    module Model
      # objectPath : pathPart (SYM_SLASH pathPart)* ;
      class ObjectPath
        attr_reader :segments

        def initialize(segments:)
          @segments = segments.freeze
          freeze
        end

        def to_s
          segments.map(&:to_s).join('/')
        end
      end

      # pathPart : IDENTIFIER pathPredicate? ;
      class PathPart
        attr_reader :attribute, :predicate

        def initialize(attribute:, predicate: nil)
          @attribute = attribute
          @predicate = predicate
          freeze
        end

        def to_s
          predicate ? "#{attribute}[#{predicate}]" : attribute
        end
      end
    end
  end
end
