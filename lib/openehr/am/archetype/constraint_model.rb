$:.unshift(File.dirname(__FILE__))
module OpenEHR
  module AM
    module Archetype
      module ConstraintModel

        require 'constraint_model/primitive'

        class ArchetypeConstraint
          attr_reader :path
          attr_accessor :parent

          def initialize(args = { })
            self.path = args[:path]
            self.parent = args[:parent]
          end

          def path=(path)
            if path.nil?
              raise ArgumentError, 'path is mandatory'
            end
            @path = path
          end

          def has_path?(path)
            return @path.include?(path)
          end

          def congruent?
            if @path.index(@parent.path) == 0
              return true
            else
              return false
            end
          end

          alias is_congruent? congruent?

          def node_conforms_to?(other)
            if @path.index(other.path) == 0
              return true
            else
              return false
            end
          end
        end

        class Cardinality
          attr_accessor :interval, :is_ordered, :is_unique

          def initialize(args = { })
            @interval = args[:interval]
            @is_ordered = args[:is_ordered]
            @is_unique = args[:is_unique]
          end

          def is_ordered?
            return @is_ordered
          end
          
          alias ordered? is_ordered?

          def is_unique?
            return @is_unique
          end

          alias unique? is_unique?

          def is_set?
            return !@is_ordered && @is_unique
          end

          alias set? is_set?

          def is_list?
            return @is_ordered && !@is_unique
          end

          alias list? is_list?

          def is_bag?
            return !@is_ordered && !@is_unique
          end

          alias bag? is_bag?
        end

        class CObject < ArchetypeConstraint
          attr_reader :rm_type_name, :node_id, :occurrences

          def initialize(args = { })
            super
            self.rm_type_name = args[:rm_type_name]
            self.node_id = args[:node_id]
            self.occurrences = args[:occurrences]
          end

          def rm_type_name=(rm_type_name)
            if rm_type_name.nil? || rm_type_name.empty?
              raise ArgumentError, 'invalid rm_type_name'
            end
            @rm_type_name = rm_type_name
          end

          def node_id=(node_id)
            if !node_id.nil? && node_id.empty?
              raise ArgumentError, 'invalid node_id'
            end
            @node_id = node_id
          end

          def occurrences=(occurrences)
            if occurrences.nil?
              raise ArgumentError, 'invaild occurrences'
            end
            @occurrences = occurrences
          end

          def self.create(args = { }, &block)
            c_object = new(args)
            if block_given?
              yield c_object
            end
            return c_object
          end
        end

        class CAttribute < ArchetypeConstraint
          attr_reader :rm_attribute_name, :existence
          attr_accessor :children

          def initialize(args = { })
            super(args)
            self.rm_attribute_name = args[:rm_attribute_name]
            self.existence = args[:existence]
            self.children = args[:children]
          end

          def rm_attribute_name=(rm_attribute_name)
            if rm_attribute_name.nil? or rm_attribute_name.empty?
              raise ArgumentError, 'invalid rm_attribute_name'
            end
            @rm_attribute_name = rm_attribute_name
          end

          def existence=(existence)
            if !existence.nil? && (existence.lower < 0 || existence.upper > 1)
              raise ArgumentError, 'invalid existence'
            end
            @existence = existence
          end
        end

        class CDefinedObject < CObject
          attr_accessor :assumed_value
          
          def initialize(args = { })
            super
            self.assumed_value = args[:assumed_value]
          end

          def has_assumed_value?
            return !@assumed_value.nil?
          end

          def default_value
            raise NotImplementedError, 'subclass should implement this method'
          end

          def valid_value?(value)
            raise NotImplementedError, 'subclass should implement this method'
          end

          def any_allowed?
            raise NotImplementedError, 'subclass should implement this method'
          end
        end

        class CPrimitiveObject < CDefinedObject
          attr_accessor :item

          def initialize(args = { })
            super
            self.item = args[:item]
          end

          def any_allowed?
            return item.nil?
          end
        end

        class CComplexObject < CDefinedObject
          attr_accessor :attributes

          def initialize(args = { })
            super
            self.attributes = args[:attributes]
          end

          def any_allowed?
            return (@attributes.nil? or @attributes.empty?)
          end

          def self.create(args = { }, &block)
            c_complex_object = new(args)
            if block_given?
              yield c_complex_object
            end
            return c_complex_object
          end
        end

        class CDomainType < CDefinedObject
          def standard_equivalent
            raise NotImplementedError, 'subclass should be defined'
          end
        end

        class CReferenceObject < CObject

        end

        class ArchetypeInternalRef < CReferenceObject
          attr_reader :target_path

          def initialize(args = { })
            super
            self.target_path = args[:target_path]
          end

          def target_path=(target_path)
            if target_path.nil? or target_path.empty?
              raise ArgumentError, 'target_path is mandatory'
            end
            @target_path = target_path
          end
        end

        class ArchetypeSlot < CReferenceObject
          attr_reader :includes, :excludes

          def initialize(args = { })
            super
            self.includes = args[:includes]
            self.excludes = args[:excludes]
          end

          def includes=(includes)
            if !includes.nil? && includes.empty?
              raise ArgumentError, 'includes should not be empty'
            end
            @includes = includes
          end
          
          def excludes=(excludes)
            if !excludes.nil? && excludes.empty?
              raise ArgumentError, 'excludes should not be empty'
            end
            @excludes = excludes
          end

          def any_allowed?
            return includes.nil? && excludes.nil?
          end

          def self.create(args = { }, &block)
            archetype_slot = new(args)
            archetype_slot.includes = args[:includes]
            archetype_slot.excludes = args[:excludes]
            if block_given?
              yield archetype_slot
            end
            return archetype_slot
          end
        end

        class ConstraintRef < CReferenceObject
          attr_reader :reference

          def initialize(args = { })
            super
            self.reference = args[:reference]
          end

          def reference=(reference)
            if reference.nil?
              raise ArgumentError, 'reference is mandatory'
            end
            @reference = reference
          end

          def self.create(args = { }, &block)
            constraint_ref = new(args)
            constraint_ref.reference = args[:reference]
            if block_given?
              yield constraint_ref
            end
            return constraint_ref
          end
        end

        class CSingleAttribute < CAttribute
          attr_reader :alternatives

          def initialize(args = { })
            super
            self.alternatives = args[:alternatives]
          end

          def alternatives=(alternatives)
            @alternatives = alternatives
          end
        end

        class CMultipleAttribute < CAttribute
          attr_accessor :members, :cardinality
          
          def initialize(args = { })
            super
            self.members = args[:members]
            self.cardinality = args[:cardinality]
          end
        end
      end # of ConstraintModel
    end # of Archetype
  end # of AM
end # of OpenEHR
  
