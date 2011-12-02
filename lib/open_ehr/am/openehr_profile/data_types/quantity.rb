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
          end
        end
      end # of DataTypes
    end # of OpenEHRProfile
  end # of AM
end # of OpenEHR
