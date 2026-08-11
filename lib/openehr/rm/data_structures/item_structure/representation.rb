# rm::data_structures::item_structure::representation
# representation module
# http://www.openehr.org/uml/release-1.0.1/Browsable/_9_0_76d0249_1109066789167_738055_2581Report.html
# refs #53
require_relative '../../common/archetyped'

module OpenEHR
  module RM
    module DataStructures
      module ItemStructure
        module Representation
          class Item < OpenEHR::RM::Common::Archetyped::Locatable
            def initialize(args = {})
              super(args)
            end
          end

          class Element < Item
            # openEHR "Null flavours" code set (terminology_id "openehr"):
            # 271 no information, 272 masked, 273 not applicable, 253 unknown.
            NULL_FLAVOUR_CODES = %w[271 272 273 253].freeze

            attr_accessor :value
            attr_reader :null_flavor
            def initialize(args = {})
              super(args)
              self.value = args[:value]
              self.null_flavor= args[:null_flavor]
            end

            def null_flavor=(null_flavor)
              if !null_flavor.nil? &&
                  !(null_flavor.defining_code.terminology_id.name == 'openehr' &&
                    NULL_FLAVOUR_CODES.include?(null_flavor.defining_code.code_string))
                raise ArgumentError, 'null_flavor is invalid'
              end
              @null_flavor = null_flavor
            end
            alias null_flavour null_flavor
            alias null_flavour= null_flavor=

            def is_null?
              return @value.nil?
            end
          end

          class Cluster < Item
            attr_reader :items

            def initialize(args = {})
              super(args)
              self.items = args[:items]
            end

            def items=(items)
              if !items.nil? and items.empty?
                raise ArgumentError, 'items should not empty'
              end
              @items = items
            end
          end
        end # of Representation
      end # of ItemStructure
    end # of DataStructures
  end # of RM
end # of OpenEHR
