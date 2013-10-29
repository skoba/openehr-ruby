module OpenEHR
  module AM
    module Template
      class OperationalTemplate
        attr_reader :language, :description

        def initialize(args = {})
          self.language = args[:language]
          self.description = args[:description]
        end

        def language=(language)
          @language = language
        end

        def description=(description)
          raise ArgumentError if description.nil?
          @description=description 
        end
      end
    end
  end
end
