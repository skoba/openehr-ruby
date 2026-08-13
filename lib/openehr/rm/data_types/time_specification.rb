# This module is related to the ticket #47
require_relative 'basic'
require_relative 'quantity/date_time'

module OpenEHR
  module RM
    module DataTypes
      module TimeSpecification
        class DvTimeSpecification < OpenEHR::RM::DataTypes::Basic::DataValue
          attr_reader :value

          def value=(value)
            raise ArgumentError, 'value must be not nil' if value.nil?
            unless value.respond_to?(:formalism) && value.respond_to?(:value)
              raise ArgumentError, 'value must be a DV_PARSABLE'
            end
            @value = value
          end

          def calendar_alignment
            raise NotImplementedError, "calendar_alignment must be implemented"
          end

          # Legacy misspelling, deliberately kept (pinned by spec). Defined
          # as a delegating method rather than `alias` so a subclass
          # override of calendar_alignment is still reached through it.
          def calender_alignment
            calendar_alignment
          end

          def event_alignment
            raise NotImplementedError, "event_alignment must be implemented"
          end

          def institution_specified
            raise NotImplementedError, "institution_specified must be implemented"
          end
        end

# I have not implemented two classes bellow,
# because I could not obtain HL7 specification related them.

        class DvGeneralTimeSpecification < DvTimeSpecification
          FORMALISM = 'HL7:GTS'

          def value=(value)
            unless value.respond_to?(:formalism) && value.formalism == FORMALISM
              raise ArgumentError, "formalism must be #{FORMALISM}"
            end
            super
          end
          # calendar_alignment / event_alignment / institution_specified
          # remain NotImplementedError (inherited from DvTimeSpecification):
          # deriving them requires parsing the full HL7 GTS set-algebra
          # (union/intersection/exclusion of interval sets), which is
          # explicitly out of scope here.
        end

        class DvPeriodicTimeSpecification < DvTimeSpecification
          PIVL_FORMALISM = 'HL7:PIVL'
          EIVL_FORMALISM = 'HL7:EIVL'

          # Single-literal PIVL: [phase_low(;phase_high)?]/(period)@ALIGN? IST?
          # e.g. "[200004181100;200004181110]/(7d)@DW IST"
          PIVL_PATTERN = %r{\A\[(?<phase_low>\d+)(?:;(?<phase_high>\d+))?\]/
                            \((?<period>\d+(?:\.\d+)?)(?<unit>[a-z]+)\)
                            (?:@(?<alignment>[A-Z]{2}))?(?<ist>\ ?IST)?\z}x

          # Single-literal EIVL: EVENT([+-]offset)? e.g. "ACM+10min"
          EIVL_PATTERN = /\A(?<event>[A-Z]+)(?:(?<sign>[+-])(?<offset>\d+(?:\.\d+)?)(?<unit>[a-z]+))?\z/

          # HL7 CalendarCycle codes (DW=day of week, HD=hour of day, ...)
          CALENDAR_CYCLE_CODES = %w[CY MY CM CW WY DM CD DY DW HD CH NH CN SN CS].freeze
          # HL7 TimingEvent codes (HS=bedtime, ACM=before breakfast, ...)
          TIMING_EVENT_CODES = %w[HS WAKE C CM CD CV AC ACM ACD ACV PC PCM PCD PCV].freeze
          # HL7 physical-quantity time units -> ISO8601 duration templates
          PERIOD_UNIT_TO_ISO8601 = { 's' => 'PT%sS', 'min' => 'PT%sM', 'h' => 'PT%sH',
                                     'd' => 'P%sD', 'wk' => 'P%sW', 'mo' => 'P%sM',
                                     'a' => 'P%sY' }.freeze

          attr_reader :period, :calendar_alignment, :event_alignment

          def value=(value)
            unless value.respond_to?(:formalism) &&
                   [PIVL_FORMALISM, EIVL_FORMALISM].include?(value.formalism)
              raise ArgumentError, "formalism must be #{PIVL_FORMALISM} or #{EIVL_FORMALISM}"
            end
            if value.formalism == PIVL_FORMALISM
              parse_pivl(value.value)
            else
              parse_eivl(value.value)
            end
            super
          end

          def institution_specified
            @institution_specified
          end
          alias institution_specified? institution_specified

          private

          def parse_pivl(raw)
            match = PIVL_PATTERN.match(raw)
            raise ArgumentError, 'value does not match HL7:PIVL syntax' unless match

            unit = match[:unit]
            unless PERIOD_UNIT_TO_ISO8601.key?(unit)
              raise ArgumentError, "unknown HL7 PIVL period unit #{unit.inspect}"
            end

            alignment = match[:alignment]
            if alignment && !CALENDAR_CYCLE_CODES.include?(alignment)
              raise ArgumentError, "unknown HL7 CalendarCycle code #{alignment.inspect}"
            end

            @period = DataTypes::Quantity::DateTime::DvDuration.new(:value => period_from(match[:period], unit))
            @calendar_alignment = alignment
            @event_alignment = nil
            @institution_specified = !match[:ist].nil?
          end

          def parse_eivl(raw)
            match = EIVL_PATTERN.match(raw)
            raise ArgumentError, 'value does not match HL7:EIVL syntax' unless match

            event = match[:event]
            unless TIMING_EVENT_CODES.include?(event)
              raise ArgumentError, "unknown HL7 TimingEvent code #{event.inspect}"
            end

            unit = match[:unit]
            if unit && !PERIOD_UNIT_TO_ISO8601.key?(unit)
              raise ArgumentError, "unknown HL7 EIVL offset unit #{unit.inspect}"
            end

            @event_alignment = event
            @calendar_alignment = nil
            @period = nil
            @institution_specified = false
          end

          def period_from(quantity, unit)
            format(PERIOD_UNIT_TO_ISO8601[unit], quantity)
          end
        end
      end
    end # of Data_Type
  end # of RM
end # of OpenEHR
