require 'active_support/core_ext/string/inflections'

module OpenEHR
  module RM
    module TypeName
      module_function

      def type_name_of(class_or_instance)
        class_of(class_or_instance).name.split('::').last.underscore.upcase
      end

      def class_for(type_name)
        registry[normalize(type_name)]
      end

      def subtype_of?(class_or_instance, type_name)
        expected = normalize(type_name)
        ancestor = class_of(class_or_instance)
        while ancestor
          return true if ancestor.name && type_name_of(ancestor) == expected

          ancestor = ancestor.superclass
        end
        false
      end

      # Accepts a spec type name in any of its forms seen across this
      # codebase - UPPER_SNAKE ('DV_QUANTITY', from the ADL/OPT
      # parsers), CamelCase ('DvQuantity', hardcoded by some
      # CDomainType constructors) or lower_snake - and normalises to
      # the UPPER_SNAKE form used as the registry key.
      def normalize(type_name)
        type_name.to_s.underscore.upcase
      end
      private_class_method :normalize

      def class_of(class_or_instance)
        class_or_instance.is_a?(Module) ? class_or_instance : class_or_instance.class
      end
      private_class_method :class_of

      def registry
        @registry ||= build_registry
      end
      private_class_method :registry

      # Skips Factory (OpenEHR::RM::Factory and the *Factory helper
      # classes in factory.rb) - those are builders, not RM types, and
      # would otherwise shadow nothing but add registry noise.
      def build_registry
        classes = {}
        visit(OpenEHR::RM, Set.new.compare_by_identity) do |klass|
          next if klass.name.end_with?('Factory')

          classes[type_name_of(klass)] ||= klass
        end
        classes
      end
      private_class_method :build_registry

      def visit(mod, seen, &block)
        mod.constants(false).each do |const_name|
          const = mod.const_get(const_name)
          next unless const.is_a?(Module)
          next if seen.include?(const)

          seen << const
          yield const if const.is_a?(Class)
          visit(const, seen, &block)
        end
      end
      private_class_method :visit
    end

    class << self
      def type_name_of(class_or_instance)
        TypeName.type_name_of(class_or_instance)
      end

      def class_for(type_name)
        TypeName.class_for(type_name)
      end

      def subtype_of?(class_or_instance, type_name)
        TypeName.subtype_of?(class_or_instance, type_name)
      end
    end
  end
end
