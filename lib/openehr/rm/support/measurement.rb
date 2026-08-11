module OpenEHR
  module RM
    module Support
      module Measurement
        # A minimal UCUM-lite syntactic checker, not a full UCUM
        # parser/conversion table: it validates that a units string is
        # *shaped* like a UCUM unit (allowed characters, balanced
        # brackets) and treats "equivalent" as exact string equality of
        # two syntactically-valid units strings. It does not perform
        # unit conversion (e.g. "kg" and "1000g" are not recognized as
        # equivalent).
        class MeasurementService
          UCUM_LITE_PATTERN = /\A[A-Za-z0-9%\/.*\[\]{}'_-]+\z/

          def self.is_valid_units_string?(units)
            return false unless units.is_a?(String) && !units.empty?
            return false unless units =~ UCUM_LITE_PATTERN

            balanced_brackets?(units, '[', ']') && balanced_brackets?(units, '{', '}')
          end

          def self.units_equivalent?(units1, units2)
            return false unless is_valid_units_string?(units1) && is_valid_units_string?(units2)

            units1 == units2
          end

          def self.balanced_brackets?(str, open, close)
            depth = 0
            str.each_char do |c|
              depth += 1 if c == open
              depth -= 1 if c == close
              return false if depth.negative?
            end
            depth.zero?
          end
          private_class_method :balanced_brackets?
        end
        module ExternalEnvironmentAccess
          def eea_terminology_svc
          end
          
          def eea_measurement_svc
          end
        end
      end # of Measurment
    end # of Support
  end # of RM
end # of OpenEHR
