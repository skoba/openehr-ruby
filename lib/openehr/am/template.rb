module OpenEHR
  module AM
    module Template
      class OperationalTemplate
        attr_reader :language

        def initialize(args = {})
          self.language=args[:language]
        end

        def language=(language)
          @language = language
        end
      end
    end
  end
end
