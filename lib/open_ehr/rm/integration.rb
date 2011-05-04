# rm::integration
# integration module
# http://www.openehr.org/uml/release-1.0.1/Browsable/_9_5_1_76d0249_1140530578205_529440_4046Report.html
# refs #42
include OpenEHR::RM::Composition::Content

module OpenEHR
  module RM
    module Integration
      class GenericEntry < ContentItem
        attr_reader :data

        def initialize(args = { })
          super(args)
          self.data = args[:data]
        end

        def data=(data)
          if data.nil?
            raise ArgumentError, 'data are mandatory'
          end
          @data = data
        end
      end
    end # of Integration
  end # of RM
end # of OpenEHR
