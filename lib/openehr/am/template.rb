module OpenEHR
  module AM
    module Template
      class OperationalTemplate
        attr_reader :language, :description, :template_id

        def initialize(args = {})
          self.template_id = args[:template_id]
          self.language = args[:language]
          self.description = args[:description]
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
