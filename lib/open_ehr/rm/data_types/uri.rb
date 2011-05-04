# This module is implemented from this UML:
#http://www.openehr.org/uml/release-1.0.1/Browsable/_9_0_76d0249_1109701308832_384250_6986Report.html
# Ticket refs #46
require 'uri/generic'

module URI
  class EHR < ::URI::Generic
    COMPONENT = [
      :scheme, :path, :fragment, :query
    ].freeze

    def self.build(args)
      tmp = Util::make_components_hash(self, args)
      super(tmp)
    end

    def initialize(*arg)
      super(*arg)
    end

    def self.use_registry
      true
    end
  end
  @@schemes['EHR'] = EHR
end

module OpenEHR
  module RM
    module DataTypes
      module URI
        class DvUri < OpenEHR::RM::DataTypes::Basic::DataValue
          def initialize(args = {})
            self.value = args[:value]
          end

          def value
            @value.to_s
          end

          def fragment_id
            @value.fragment
          end

          def path
            @value.path
          end

          def query
            @value.query
          end

          def scheme
            @value.scheme
          end

          def value=(value)
            raise ArgumentError, "value is empty" if value.nil?
            parse(value)
          end

          private

          def parse(value)
            @value = ::URI.parse(value)
          end
        end

        class DvEhrUri < DvUri
          def initialize(value)
            super(value)
          end

          def value=(value)
            raise ArgumentError, "scheme must be ehr" if !(value =~ /^ehr/i)
            @value = parse(value)
          end
        end # of DV_EHR_URI
      end # of URI
    end # of DataTypes
  end # of RM
end # of OpenEHR
