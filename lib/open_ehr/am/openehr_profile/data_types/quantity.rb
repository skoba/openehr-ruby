module OpenEHR
  module AM
    module OpenEHRProfile
      module DataTypes
        module Quantity
          include OpenEHR::AM::Archetype::ConstraintModel

          class CDvQuantity < CDomainType
          end
          
          class CDvOrdinal < CDomainType
            attr_accessor :list
            def initialize(args = { })
              super
              self.list = args[:list]
            end

            def any_allowed?
              @list.nil?
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
              if @precision.upper == -1 && @precision.lower == -1
                return true
              else
                return false
              end
            end
          end
        end
      end # of DataTypes
    end # of OpenEHRProfile
  end # of AM
end # of OpenEHR
