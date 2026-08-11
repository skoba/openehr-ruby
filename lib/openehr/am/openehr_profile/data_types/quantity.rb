require_relative '../../archetype/constraint_model'

module OpenEHR
  module AM
    module OpenEHRProfile
      module DataTypes
        module Quantity
          class CDvQuantity < OpenEHR::AM::Archetype::ConstraintModel::CDomainType
            attr_accessor :property, :list

            def initialize(args = { })
              super
              self.property = args[:property]
              self.list = args[:list]
            end

            def any_allowed?
              if @property.nil? && @list.nil?
                return true
              else
                return false
              end
            end

            def valid_value?(value)
              return true if any_allowed?
              return false if list.nil? || value.nil?

              list.any? { |item| item.matches?(value) }
            end
          end
          
          class CDvOrdinal < OpenEHR::AM::Archetype::ConstraintModel::CDomainType
            attr_accessor :list
            def initialize(args = { })
              super
              self.list = args[:list]
            end

            def any_allowed?
              @list.nil?
            end

            def valid_value?(value)
              return true if any_allowed?
              return false unless value.respond_to?(:value) && value.respond_to?(:symbol)

              list.any? do |item|
                item.value == value.value && item.symbol.code_string == value.symbol.code_string
              end
            end
          end

          class CQuantityItem
            attr_accessor :magnitude, :precision
            attr_reader :units

            def initialize(args = { })
              self.magnitude = args[:magnitude]
              self.precision = args[:precision]
              self.units = args[:units]
            end

            def units=(units)
              if units.nil? or units.empty?
                raise ArgumentError, 'units are mandatory'
              end
              @units = units
            end

            def precision_unconstrained?
              return true if @precision.nil?
              if @precision.upper == -1 && @precision.lower == -1
                return true
              else
                return false
              end
            end

            def matches?(value)
              return false unless value.respond_to?(:units) && value.units == units

              magnitude_matches?(value.magnitude) &&
                precision_matches?(value.respond_to?(:precision) ? value.precision : nil)
            end

            private

            def magnitude_matches?(value_magnitude)
              return true if magnitude.nil?
              return magnitude.has?(value_magnitude) if magnitude.respond_to?(:has?)

              magnitude == value_magnitude
            end

            def precision_matches?(value_precision)
              return true if precision_unconstrained?
              return precision.has?(value_precision) if precision.respond_to?(:has?)

              precision == value_precision
            end
          end
        end
      end # of DataTypes
    end # of OpenEHRProfile
  end # of AM
end # of OpenEHR
