module OpenEHR
  module AM
    module Template
      class OperationalTemplate
        attr_reader :uid, :concept, :language, :description, :template_id, :definition, :component_terminologies

        def initialize(args = {})
          self.uid = args[:uid]
          self.concept = args[:concept]
          self.template_id = args[:template_id]
          self.language = args[:language]
          self.description = args[:description]
          self.definition = args[:definition]
          self.component_terminologies = args[:component_terminologies]
        end

        def uid=(uid)
          @uid = uid
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

        def component_terminologies=(component_terminologies)
          @component_terminologies = component_terminologies
        end
      end
    end
  end
end
