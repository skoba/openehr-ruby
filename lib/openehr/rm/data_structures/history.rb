# rm::data_structures::history
# history module
# http://www.openehr.org/uml/release-1.0.1/Browsable/_9_0_76d0249_1109157527311_729550_7234Report.html
# refs #55
require 'time'
require 'active_support/core_ext'

module OpenEHR
  module RM
    module DataStructures
      module History
        class History < OpenEHR::RM::DataStructures::DataStructure
          attr_reader :origin, :events
          attr_accessor :duration, :period, :summary

          def initialize(args = { })
            super(args)
            self.origin = args[:origin]
            self.duration = args[:duration]
            self.period = args[:period]
            self.events = args[:events]
            self.summary = args[:summary]
          end

          def origin=(origin)
            raise ArgumentError, 'origin is mandatory' if origin.nil?
            @origin = origin
          end

          def events=(events)
            if !events.nil? and events.empty?
              raise ArgumentError, 'events should not be empty'
            end
            @events = events
          end

          def is_periodic?
            return !@period.nil?
          end
        end

        class Event < OpenEHR::RM::Common::Archetyped::Locatable
          attr_reader :data, :time
          attr_accessor :state

          def initialize(args = { })
            super(args)
            self.data = args[:data]
            self.time = args[:time]
            self.state = args[:state]
          end

          def data=(data)
            raise ArgumentError, 'data is mandatory' if data.nil?
            @data = data
          end

          def time=(time)
            raise ArgumentError, 'time is mandatory' if time.nil?
            @time = time
          end

          def offset
            return @time.diff(@parent.origin)
          end
        end

        class PointEvent < Event

        end

        class IntervalEvent < Event
          attr_reader :width, :math_function
          attr_accessor :sample_count

          def initialize(args = { })
            super(args)
            self.width = args[:width]
            self.math_function = args[:math_function]
            self.sample_count = args[:sample_count]
          end

          def width=(width)
            raise ArgumentError, 'width is mandatory' if width.nil?
            @width = width
          end

          def math_function=(math_function)
            if math_function.nil?
              raise ArgumentError, 'math_function is mandatory'
            end
            @math_function = math_function
          end

          def interval_start_time
            date_time = ::Time.iso8601(time.as_string)
            start_time = (@width.years).years.ago date_time
            start_time = (@width.months).months.ago start_time
            start_time = (@width.days).days.ago start_time
            start_time = (@width.hours).hours.ago start_time
            start_time = (@width.minutes).minutes.ago start_time
            seconds = @width.seconds
            unless @width.fractional_second.nil?
              seconds += @width.fractional_second
            end
            start_time = seconds.ago start_time
            return OpenEHR::RM::DataTypes::Quantity::DateTime::DvDateTime.new(:value => start_time.iso8601)
          end
        end
      end # end of History
    end # end of DataStructure
  end # end of RM
end # end of OpenEHR
