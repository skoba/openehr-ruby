module OpenEHR
  module AM
    module Archetype
      module ConstraintModel
        class ArchetypeConstraint
          attr_reader :path
          attr_accessor :parent

          def initialize(args = { })
            self.path = args[:path] if args[:path]
            self.parent = args[:parent]
          end

          def path=(path)
            if path.nil?
              raise ArgumentError, 'path is mandatory'
            end
            @path = path
          end

          def has_path?(search_path)
            path.include?(search_path)
          end

          def congruent?
            path.index(@parent.path) == 0
          end

          alias is_congruent? congruent?

          def node_conforms_to?(other)
            path.index(other.path) == 0
          end

          protected

          def parent_path
            parent ? parent.path : ''
          end

          # Nil-safe interval subset check shared by the
          # occurrences/existence/cardinality conformance rules: an
          # unconstrained parent (nil) accepts anything, an
          # unconstrained child (nil) only conforms to an
          # unconstrained parent, and otherwise the child interval
          # must be a genuine subset of the parent's.
          def interval_conforms_to?(mine, other)
            return true if other.nil?
            return false if mine.nil?

            mine.subset_of?(other)
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

          def path
            @path || calculate_path
          end

          def to_rm
            @rm ||= OpenEHR::RM::Factory.create(rm_type_name, params)
          end

          # Whether this (potentially specialised) node is a legal
          # redefinition of +other+, the corresponding node in the
          # flat parent archetype: same node_id lineage (at0001.1
          # specialises at0001), same rm_type_name (subtype checking
          # is deferred until the RM type-name helper lands), and
          # occurrences no wider than the parent's.
          def node_conforms_to?(other)
            return false if other.nil?

            node_id_conforms_to?(other.node_id) &&
              rm_type_name == other.rm_type_name &&
              interval_conforms_to?(occurrences, other.occurrences)
          end

          private

          def node_id_conforms_to?(other_node_id)
            return true if node_id == other_node_id
            return false if node_id.nil? || other_node_id.nil?

            node_id.start_with?(other_node_id + '.') &&
              node_id[(other_node_id.length + 1)..-1] =~ /\A\d+(\.\d+)*\z/
          end

          def calculate_path
            path_left_part = parent_path
            path_left_part = '/' if path_left_part == ''

            if node_id && path_left_part != '/'
              path_right_part = '[' + node_id + ']'
            else
              path_right_part = ''
            end

            @path = path_left_part + path_right_part
          end

          def params
            {:path => path, :archetype_node_id => node_id}
          end
        end

        class CAttribute < ArchetypeConstraint
          attr_reader :rm_attribute_name, :existence, :children

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

          def children=(children)
            @children = children.inject([]) do |array, child|
              child.parent = self
              array << child
            end if children
          end

          def has_children?
            !@children.nil? and !@children.empty?
          end

          def path
            @path || calculate_path
          end

          # Whether this (potentially specialised) attribute node is
          # a legal redefinition of +other+: same rm_attribute_name
          # and an existence no wider than the parent's.
          def node_conforms_to?(other)
            return false if other.nil?

            rm_attribute_name == other.rm_attribute_name &&
              interval_conforms_to?(existence, other.existence)
          end

          private

          def calculate_path
            path_left_part = parent_path
            path_left_part += '/' if path_left_part != '/'

            @path = path_left_part + rm_attribute_name
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

          %w(assumed_value assumed_value= has_assumed_value? default_value
            valid_value?).each do |m|
            define_method(m) do |*args|
              self.item.send(m, *args) if !self.item.nil?
            end
          end

          def method_missing(meth, *args)
            if !self.item.nil? && self.item.respond_to?(meth)
              self.item.send(meth, *args)
            else
              super
            end
          end
        end
   
        class CComplexObject < CDefinedObject
          attr_accessor :attributes

          def initialize(args = { })
            super
            self.attributes = args[:attributes]
          end

          def attributes=(attributes)
            @attributes = attributes.inject([]) do |array, child|
              child.parent = self
              array << child
            end if attributes
            @attributes = [] if attributes.nil?
          end

          def has_attributes?
            !attributes.nil? and !attributes.empty?
          end

          def any_allowed?
            return (@attributes.nil? or @attributes.empty?)
          end

          # Recursively checks +value+ (an RM instance) against this
          # node's constraints: rm_type_name conformance (RM subtypes
          # allowed), archetype_node_id (when this node specifies
          # one), then each attribute's existence/cardinality and its
          # children constraints. ArchetypeSlot/ArchetypeInternalRef/
          # ConstraintRef children are accepted permissively (v1 does
          # not resolve slot-fillers or internal references).
          def valid_value?(value)
            return false if value.nil?
            return false unless node_id_matches?(value)
            return false unless OpenEHR::RM.subtype_of?(value, rm_type_name)
            return true if any_allowed?

            attributes.all? { |attribute| attribute_conforms?(attribute, attribute_values(attribute, value)) }
          end

          # Diagnostic counterpart to valid_value?, for building
          # path-annotated instance-validation reports: walks the same
          # rules but returns the first [failing_constraint_node,
          # failing_rm_value] pair found (depth-first) instead of a
          # bare boolean, or nil when +value+ fully conforms.
          def find_violation(value)
            if value.nil? || !node_id_matches?(value) || !OpenEHR::RM.subtype_of?(value, rm_type_name)
              return [self, value]
            end
            return nil if any_allowed?

            attributes.each do |attribute|
              violation = attribute_violation(attribute, value)
              return violation if violation
            end
            nil
          end

          private

          def attribute_violation(attribute, value)
            rm_values = attribute_values(attribute, value)
            return [self, value] unless interval_satisfied?(attribute.existence, rm_values.empty? ? 0 : 1)

            if attribute.is_a?(CMultipleAttribute)
              return [self, value] unless interval_satisfied?(attribute.cardinality&.interval, rm_values.size)
              return [self, value] unless children_occurrences_satisfied?(attribute.children, rm_values)
            end

            children = attribute.children || []
            rm_values.each do |v|
              matched = children.find { |child| child_matches?(child, v) }
              return [self, v] if matched.nil?
              next unless matched.respond_to?(:find_violation)

              violation = matched.find_violation(v)
              return violation if violation
            end
            nil
          end

          def node_id_matches?(value)
            return true if node_id.nil?
            return true unless value.respond_to?(:archetype_node_id)

            value.archetype_node_id == node_id
          end

          def attribute_values(attribute, value)
            name = attribute.rm_attribute_name
            Array(value.respond_to?(name) ? value.send(name) : nil)
          end

          def attribute_conforms?(attribute, rm_values)
            present = rm_values.empty? ? 0 : 1
            return false unless interval_satisfied?(attribute.existence, present)

            if attribute.is_a?(CMultipleAttribute)
              return false unless interval_satisfied?(attribute.cardinality&.interval, rm_values.size)
              return false unless children_occurrences_satisfied?(attribute.children, rm_values)
            end

            children = attribute.children || []
            rm_values.all? { |v| children.any? { |child| child_matches?(child, v) } }
          end

          def interval_satisfied?(interval, count)
            interval.nil? || interval.has?(count)
          end

          def children_occurrences_satisfied?(children, rm_values)
            (children || []).all? do |child|
              next true if child.occurrences.nil?

              child.occurrences.has?(rm_values.count { |v| child_matches?(child, v) })
            end
          end

          def child_matches?(child, rm_value)
            return true if child.is_a?(ArchetypeSlot) ||
                           child.is_a?(ArchetypeInternalRef) ||
                           child.is_a?(ConstraintRef)

            child.valid_value?(rm_value)
          end

          public

          # Builds the minimal RM instance satisfying this node's
          # mandatory constraints: only attributes with existence
          # lower >= 1 are populated, each from its first child
          # alternative's own default_value (recursively), and
          # CMultipleAttribute gets exactly cardinality.interval.lower
          # (or 1) copies of it. Returns nil - rather than raising -
          # whenever a mandatory field has no derivable default, since
          # that means no minimal instance can be built at all.
          def default_value
            return nil if any_allowed?

            klass = OpenEHR::RM.class_for(rm_type_name)
            return nil if klass.nil?

            params = mandatory_attribute_params
            return nil if params.nil?

            klass.new(node_id.nil? ? params : params.merge(:archetype_node_id => node_id))
          rescue ArgumentError, NotImplementedError
            nil
          end

          private

          def mandatory_attribute_params
            attributes.each_with_object({}) do |attribute, params|
              next unless mandatory_attribute?(attribute)

              value = attribute_default(attribute)
              return nil if value.nil?

              params[attribute.rm_attribute_name.to_sym] = value
            end
          end

          def mandatory_attribute?(attribute)
            attribute.existence.nil? || attribute.existence.lower.to_i >= 1
          end

          def attribute_default(attribute)
            children = attribute.children || []
            return nil if children.empty?

            child = children.first
            return nil if child.is_a?(ArchetypeSlot) ||
                          child.is_a?(ArchetypeInternalRef) ||
                          child.is_a?(ConstraintRef)

            if attribute.is_a?(CMultipleAttribute)
              multiple_default(child, attribute.cardinality)
            else
              child.default_value
            end
          end

          def multiple_default(child, cardinality)
            value = child.default_value
            return nil if value.nil?

            count = cardinality&.interval&.lower
            count = 1 if count.nil? || count < 1

            Array.new(count) { value }
          end
        end

        class CDomainType < CDefinedObject
          def standard_equivalent
            raise NotImplementedError, 'subclass should be defined'
          end
        end

        class CArchetypeRoot <CComplexObject
          attr_reader :slot_node_id, :archetype_id

          def initialize(args = {})
            super
            self.slot_node_id = args[:slot_node_id]
            self.archetype_id = args[:archetype_id]
          end

          def slot_node_id=(slot_node_id)
            raise ArgumentError if !slot_node_id.nil? && slot_node_id.empty?
            @slot_node_id = slot_node_id
          end

          def archetype_id=(archetype_id)
            raise ArgumentError if archetype_id.nil?
            @archetype_id = archetype_id
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

          # Adds cardinality⊆ on top of CAttribute's rm_attribute_name
          # and existence conformance rules.
          def node_conforms_to?(other)
            return false unless super

            mine = cardinality ? cardinality.interval : nil
            others = other.cardinality ? other.cardinality.interval : nil
            interval_conforms_to?(mine, others)
          end
        end
      end # of ConstraintModel
    end # of Archetype
  end # of AM
end # of OpenEHR
