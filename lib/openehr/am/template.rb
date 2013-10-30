module OpenEHR
  module AM
    module Template
      class OperationalTemplate
        attr_reader :concept, :language, :description, :template_id

        def initialize(args = {})
          self.concept = args[:concept]
          self.template_id = args[:template_id]
          self.language = args[:language]
          self.description = args[:description]
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
      end
    end
  end
end
