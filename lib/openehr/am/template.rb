require_relative 'archetype'

module OpenEHR
  module AM
    module Template
      # OPERATIONAL_TEMPLATE class represents a "compiled" template derived from 
      # a source TEMPLATE by a "flattening" process, used for generating and 
      # validating reference model instance data.
      # According to openEHR AOM2 specification, it inherits from AUTHORED_ARCHETYPE.
      class OperationalTemplate < OpenEHR::AM::Archetype::Archetype
        attr_reader :component_terminologies, :terminology_extracts, :template_id

        def initialize(args = {})
          # template_id must be validated before delegating to Archetype#initialize:
          # OPERATIONAL_TEMPLATE identifies itself by template_id, and archetype_id
          # is derived from it below, so an absent template_id must fail with a
          # template-specific message rather than falling through to Archetype's
          # own (unrelated) mandatory-field checks.
          self.template_id = args[:template_id]

          # Initialize parent archetype with template-specific archetype_id
          template_args = args.dup
          template_args[:archetype_id] = args[:template_id] if args[:template_id] && !args[:archetype_id]

          super(template_args)

          self.component_terminologies = args[:component_terminologies] || {}
          self.terminology_extracts = args[:terminology_extracts] || {}
        end

        def template_id=(template_id)
          if template_id.nil?
            raise ArgumentError, 'template_id is mandatory for operational template'
          end
          @template_id = template_id
          # Update archetype_id to match template_id for consistency
          @archetype_id = template_id if template_id
        end

        # An operational template's concept is commonly derived from its
        # archetype_id (see #concept below) rather than supplied explicitly,
        # so unlike Archetype#concept= it must not require a value up front.
        def concept=(concept)
          @concept = concept
        end

        # AuthoredResource#description has no mandatory check, but an
        # operational template always carries its own resource description.
        def description=(description)
          if description.nil?
            raise ArgumentError, 'description is mandatory'
          end
          @description = description
        end

        def component_terminologies=(component_terminologies)
          @component_terminologies = component_terminologies || {}
        end

        def terminology_extracts=(terminology_extracts)
          @terminology_extracts = terminology_extracts || {}
        end

        # Returns true if this is a valid operational template
        def is_valid_operational_template?
          return false if template_id.nil?
          return false if definition.nil?
          return false if component_terminologies.nil?
          true
        end

        # Returns whether the template is specialized (should be true for operational templates)
        def is_specialized?
          !parent_archetype_id.nil?
        end

        # Get all archetype identifiers referenced in this operational template
        def referenced_archetype_ids
          component_terminologies.keys
        end

        # Get terminology for a specific archetype
        def terminology_for_archetype(archetype_id)
          component_terminologies[archetype_id]
        end

        # Override concept to use template concept or fallback to archetype concept
        def concept
          @concept || (archetype_id ? archetype_id.concept_name : nil)
        end

        # Compatibility method for backward compatibility with existing tests
        def language
          original_language
        end

        # Compatibility setter for language (maps to original_language)
        def language=(language)
          self.original_language = language
        end
      end
    end
  end
end
