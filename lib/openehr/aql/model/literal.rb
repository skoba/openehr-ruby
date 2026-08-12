module OpenEHR
  module AQL
    module Model
      # primitive : STRING | numericPrimitive | DATE | TIME | DATETIME | BOOLEAN | NULL ;
      class Literal
        attr_reader :value

        def initialize(value:)
          @value = value
          freeze
        end
      end
    end
  end
end
