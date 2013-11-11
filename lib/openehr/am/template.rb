module OpenEHR
  module AM
    module Template
      class OperationalTemplate
        attr_reader :concept, :language, :description, :template_id, :definition

        def initialize(args = {})
          self.concept = args[:concept]
          self.template_id = args[:template_id]
          self.language = args[:language]
          self.description = args[:description]
          self.definition = args[:definition]
        end

        def concept=(concept)
          raise ArgumentError if concept.nil?
          @concept = concept
        end

        def language=(language)
          @language = language
        end

        def template_id=(template_id)
          raise ArgumentError if template_id.nil?
          @template_id = template_id
        end

        def description=(description)
          raise ArgumentError if description.nil?
          @description=description 
        end

        def definition=(definition)
          raise ArgumentError if definition.nil?
          @definition = definition
        end
      end
    end
  end
end
