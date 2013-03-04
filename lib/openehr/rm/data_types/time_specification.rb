# This module is related to the ticket #47

module OpenEHR
  module RM
    module DataTypes
      module TimeSpecification
        class DvTimeSpecification < OpenEHR::RM::DataTypes::Basic::DataValue
          attr_reader :value

          def initialize(value)
            self.value=(value)
          end

          def value=(value)
            raise ArgumentError, 'value must be not nil' if value.nil?
            @value = value
          end
          
          def calender_alignment
            raise NotImlementedError, "calender_alignment must be implemented"
          end

          def event_alignment
            raise NotImlementedError, "event_alignment must be implemented"
          end

          def institution_specified
            raise NotImlementedError, "institution_specified must be implemented"
          end
        end

# I have not implemented two classes bellow,
# because I could not obtain HL7 specification related them.


        class DvGeneralTimeSpecification < DvTimeSpecification
          attr_reader :value
          def initialize(value)
            super(value)
          end
          def value=(value)
            raise ArgumentError, "value is not valied" unless value.formalism.is_equal?('HL7:GTS')
            @value = value
          end
          private
          def value_valid(value)
          end
        end

        class DvPeriodicTimeSpecification < DvTimeSpecification
          attr_reader :value, :calender_alignment, :event_alingment, :period
          def initialize(value)
            value_valid(value)
            super(value)
          end
          def value=(value)
            unless value.formalism.is_equal('HL7:PIVL') or value.formalism.is_equal('HL7:EIVL')
              raise ArgumentError, "value is not valid"
            end
            if value.formalism('HL7:PIVL')
              /^\[(\d+)\;?(\d+)?\]\/\((\d+\w+)\)(@(\w+?))?(IST)?$/ =~ value
              interval1, interval2, difference, allignment = $1, $2, $3, $5
            end
            if value
            end
          end

          def institution_specified?

          end
        end
      end
    end # of Data_Type
  end # of RM
end # of OpenEHR
